variable "family" {
  description = "Task definition family. Each change registers a new revision under it."
  type        = string
}

variable "cpu" {
  description = "Task-level CPU units (1024 = 1 vCPU). Required for Fargate, where only certain cpu/memory pairs are valid."
  type        = number
  default     = null
}

variable "memory" {
  description = "Task-level memory in MiB. Required for Fargate."
  type        = number
  default     = null
}

variable "network_mode" {
  description = "Docker networking mode: 'awsvpc' (required for Fargate), 'bridge', 'host' or 'none'."
  type        = string
  default     = "awsvpc"

  validation {
    condition     = contains(["awsvpc", "bridge", "host", "none"], var.network_mode)
    error_message = "network_mode must be 'awsvpc', 'bridge', 'host' or 'none'."
  }
}

variable "requires_compatibilities" {
  description = "Launch types the task definition is validated against: FARGATE, EC2, or both."
  type        = list(string)
  default     = ["FARGATE"]

  validation {
    condition = length(var.requires_compatibilities) > 0 && alltrue([
      for c in var.requires_compatibilities : contains(["FARGATE", "EC2", "EXTERNAL", "MANAGED_INSTANCES"], c)
    ])
    error_message = "requires_compatibilities must list at least one of FARGATE, EC2, EXTERNAL or MANAGED_INSTANCES."
  }
}

variable "execution_role_arn" {
  description = "Role ECS itself assumes to pull images from private ECR, read secrets, and write logs. Required for Fargate tasks that log to CloudWatch or use secrets."
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "Role the containers assume at runtime to call AWS APIs. Null for none."
  type        = string
  default     = null
}

variable "operating_system_family" {
  description = "Runtime operating system, such as LINUX or WINDOWS_SERVER_2022_CORE."
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "Runtime CPU architecture: X86_64 or ARM64. The image must be built for it."
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64."
  }
}

variable "ephemeral_storage_gib" {
  description = "Fargate ephemeral storage in GiB, 21-200. Null keeps the 20 GiB default."
  type        = number
  default     = null

  validation {
    condition     = var.ephemeral_storage_gib == null || try(var.ephemeral_storage_gib >= 21 && var.ephemeral_storage_gib <= 200, false)
    error_message = "ephemeral_storage_gib must be between 21 and 200."
  }
}

variable "log_retention_days" {
  description = "Retention of the task's CloudWatch log group, /ecs/<family>. 0 keeps logs forever."
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of the values CloudWatch Logs accepts, such as 7, 14, 30, 90, 365, or 0 for forever."
  }
}

variable "volumes" {
  description = "Task volumes containers can mount by name. Set efs to back one with an EFS file system; leave it null for a scratch volume that lives as long as the task."
  type = list(object({
    name = string
    efs = optional(object({
      file_system_id     = string
      root_directory     = optional(string)
      transit_encryption = optional(bool, true)
      access_point_id    = optional(string)
      iam_authorization  = optional(bool, false)
    }))
  }))
  default = []
}

variable "containers" {
  description = "Containers in the task. Each logs to the task's CloudWatch log group under its own stream prefix."
  type = list(object({
    name               = string
    image              = string
    essential          = optional(bool, true)
    cpu                = optional(number)
    memory             = optional(number)
    memory_reservation = optional(number)

    # name is what Service Connect and load balancers refer to; app_protocol (http, http2, grpc)
    # lets Service Connect collect protocol-level metrics.
    port_mappings = optional(list(object({
      container_port = number
      host_port      = optional(number)
      protocol       = optional(string, "tcp")
      name           = optional(string)
      app_protocol   = optional(string)
    })), [])

    environment = optional(map(string), {})
    # value_from: a Secrets Manager ARN (optionally ending :json-key::) or an SSM parameter ARN.
    secrets = optional(list(object({
      name       = string
      value_from = string
    })), [])

    command                  = optional(list(string), [])
    entry_point              = optional(list(string), [])
    working_directory        = optional(string)
    user                     = optional(string)
    readonly_root_filesystem = optional(bool, false)

    health_check = optional(object({
      command      = list(string)
      interval     = optional(number, 30)
      timeout      = optional(number, 5)
      retries      = optional(number, 3)
      start_period = optional(number, 0)
    }))

    mount_points = optional(list(object({
      source_volume  = string
      container_path = string
      read_only      = optional(bool, false)
    })), [])

    depends_on = optional(list(object({
      container_name = string
      condition      = optional(string, "START")
    })), [])

    enable_logging = optional(bool, true)
  }))

  validation {
    condition     = length(var.containers) > 0 && length([for c in var.containers : c if c.essential]) > 0
    error_message = "containers needs at least one container, and at least one of them must be essential."
  }

  validation {
    condition     = length(distinct([for c in var.containers : c.name])) == length(var.containers)
    error_message = "Container names must be unique within the task definition."
  }

  validation {
    condition = alltrue(flatten([
      for c in var.containers : [
        for p in c.port_mappings : contains(["tcp", "udp"], p.protocol) && (p.app_protocol == null || contains(["http", "http2", "grpc"], try(p.app_protocol, "")))
      ]
    ]))
    error_message = "port_mappings protocol must be tcp or udp, and app_protocol http, http2 or grpc."
  }

  validation {
    condition = alltrue(flatten([
      for c in var.containers : [for d in c.depends_on : contains(["START", "COMPLETE", "SUCCESS", "HEALTHY"], d.condition)]
    ]))
    error_message = "depends_on condition must be START, COMPLETE, SUCCESS or HEALTHY."
  }

  validation {
    condition = alltrue([
      for c in var.containers : c.health_check == null || try(
        c.health_check.interval >= 5 && c.health_check.interval <= 300 &&
        c.health_check.timeout >= 2 && c.health_check.timeout <= 60 &&
        c.health_check.retries >= 1 && c.health_check.retries <= 10 &&
        c.health_check.start_period >= 0 && c.health_check.start_period <= 300 &&
        length(c.health_check.command) > 0, false
      )
    ])
    error_message = "health_check needs a command, interval 5-300, timeout 2-60, retries 1-10 and start_period 0-300 seconds."
  }
}

variable "skip_destroy" {
  description = "Keep old revisions registered (ACTIVE) when Terraform replaces or destroys them, so running services and rollbacks can still use them."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the task definition and its log group."
  type        = map(string)
  default     = {}
}
