variable "name" {
  description = "Name of the ECS service."
  type        = string
}

variable "cluster" {
  description = "Cluster the service runs in, by name or ARN."
  type        = string
}

variable "task_definition" {
  description = "Task definition to run: a full ARN, family:revision, or a family alone for its latest ACTIVE revision."
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to keep running. With autoscaling on, each apply that changes the service resets the count to this value and autoscaling then moves it back within its bounds."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0 && floor(var.desired_count) == var.desired_count
    error_message = "desired_count must be a whole number, 0 or more."
  }
}

variable "launch_type" {
  description = "FARGATE, EC2 or EXTERNAL. Leave null to use capacity_provider_strategy, or the cluster's default strategy when that is empty too."
  type        = string
  default     = null

  validation {
    condition     = var.launch_type == null || contains(["FARGATE", "EC2", "EXTERNAL"], coalesce(var.launch_type, "-"))
    error_message = "launch_type must be FARGATE, EC2 or EXTERNAL."
  }
}

variable "capacity_provider_strategy" {
  description = "How to spread this service's tasks across the cluster's capacity providers. Overrides the cluster default; cannot be combined with launch_type."
  type = list(object({
    capacity_provider = string
    weight            = optional(number, 1)
    base              = optional(number, 0)
  }))
  default = []

  validation {
    condition     = length([for s in var.capacity_provider_strategy : s if s.base > 0]) <= 1
    error_message = "Only one capacity provider in capacity_provider_strategy can have a base above 0."
  }
}

variable "subnet_ids" {
  description = "Subnets for the tasks' network interfaces. Required when the task definition uses awsvpc networking (always the case on Fargate)."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups for the tasks' network interfaces (awsvpc only)."
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Give each task a public IP (awsvpc on Fargate only). Needed in public subnets without a NAT gateway to pull images."
  type        = bool
  default     = false
}

variable "load_balancers" {
  description = "Target groups the service registers its tasks with. container_name and container_port must match a container and port mapping in the task definition."
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

variable "health_check_grace_period_seconds" {
  description = "Seconds after a task starts during which failing load balancer health checks are ignored. Applies only with load_balancers."
  type        = number
  default     = 60
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower bound on running tasks during a deployment, as a percentage of desired_count."
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Upper bound on running tasks during a deployment, as a percentage of desired_count."
  type        = number
  default     = 200

  validation {
    condition     = var.deployment_maximum_percent >= 100
    error_message = "deployment_maximum_percent must be at least 100."
  }
}

variable "deployment_circuit_breaker" {
  description = "Stop a deployment whose tasks keep failing to reach steady state, and optionally roll back to the last working one."
  type = object({
    enable   = optional(bool, true)
    rollback = optional(bool, true)
  })
  default = {}
}

variable "availability_zone_rebalancing" {
  description = "ENABLED lets ECS move tasks to even out Availability Zones. Needs deployment_maximum_percent above 100 for headroom."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.availability_zone_rebalancing)
    error_message = "availability_zone_rebalancing must be ENABLED or DISABLED."
  }
}

variable "enable_execute_command" {
  description = "Allow ECS Exec (shell access) into this service's tasks. The task role needs the ssmmessages permissions."
  type        = bool
  default     = false
}

variable "propagate_tags" {
  description = "Copy tags to the tasks from the SERVICE, the TASK_DEFINITION, or NONE."
  type        = string
  default     = "SERVICE"

  validation {
    condition     = contains(["SERVICE", "TASK_DEFINITION", "NONE"], var.propagate_tags)
    error_message = "propagate_tags must be SERVICE, TASK_DEFINITION or NONE."
  }
}

variable "force_new_deployment" {
  description = "Restart every task on each apply that changes the service, even if the task definition did not change — useful for picking up a re-pushed image tag such as :latest."
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "Make the apply wait until the service reaches steady state, so a failing deployment fails the apply."
  type        = bool
  default     = false
}

variable "service_connect" {
  description = "ECS Service Connect. Set enabled to join a namespace; add services to publish this service's ports to others. Joining with no services makes it a client only."
  type = object({
    enabled   = optional(bool, false)
    namespace = optional(string)
    services = optional(list(object({
      # A named port mapping in the task definition.
      port_name      = string
      discovery_name = optional(string)
      # How clients address it: dns_name:port. dns_name defaults to discovery_name (or port_name).
      client_alias_port     = number
      client_alias_dns_name = optional(string)
    })), [])
  })
  default = {}

  validation {
    condition     = var.service_connect.enabled || length(var.service_connect.services) == 0
    error_message = "service_connect services need service_connect enabled."
  }
}

variable "autoscaling" {
  description = "Application Auto Scaling for the service's task count."
  type = object({
    enabled      = optional(bool, false)
    min_capacity = optional(number, 1)
    max_capacity = optional(number, 4)
    policies = optional(list(object({
      name = string
      # ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization, or ALBRequestCountPerTarget.
      metric       = string
      target_value = number
      # Required for ALBRequestCountPerTarget: app/<lb-name>/<lb-id>/targetgroup/<tg-name>/<tg-id>.
      resource_label     = optional(string)
      scale_in_cooldown  = optional(number, 300)
      scale_out_cooldown = optional(number, 60)
      disable_scale_in   = optional(bool, false)
    })), [])
  })
  default = {}

  validation {
    condition     = !var.autoscaling.enabled || (var.autoscaling.min_capacity >= 0 && var.autoscaling.min_capacity <= var.autoscaling.max_capacity)
    error_message = "autoscaling min_capacity must be 0 or more and not above max_capacity."
  }

  validation {
    condition = alltrue([
      for p in var.autoscaling.policies :
      contains(["ECSServiceAverageCPUUtilization", "ECSServiceAverageMemoryUtilization", "ALBRequestCountPerTarget"], p.metric)
    ])
    error_message = "autoscaling policy metric must be ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization or ALBRequestCountPerTarget."
  }

  validation {
    condition = alltrue([
      for p in var.autoscaling.policies : p.metric != "ALBRequestCountPerTarget" || try(trimspace(p.resource_label), "") != ""
    ])
    error_message = "An ALBRequestCountPerTarget policy needs resource_label (app/<lb-name>/<lb-id>/targetgroup/<tg-name>/<tg-id>)."
  }

  validation {
    condition     = length(distinct([for p in var.autoscaling.policies : p.name])) == length(var.autoscaling.policies)
    error_message = "autoscaling policy names must be unique."
  }
}

variable "tags" {
  description = "Tags applied to the service and its autoscaling resources."
  type        = map(string)
  default     = {}
}
