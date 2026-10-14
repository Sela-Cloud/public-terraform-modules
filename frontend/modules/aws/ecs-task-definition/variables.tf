variable "region" {
  description = "The AWS Region in which the resources will be created."
  type        = string
}

variable "ecs_task_definition" {
  description = "ECS task definitions, keyed by family."
  type = map(object({
    family                   = string
    cpu                      = optional(number)
    memory                   = optional(number)
    network_mode             = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])
    execution_role_arn       = optional(string)
    task_role_arn            = optional(string)
    operating_system_family  = optional(string, "LINUX")
    cpu_architecture         = optional(string, "X86_64")
    ephemeral_storage_gib    = optional(number)
    log_retention_days       = optional(number, 30)
    skip_destroy             = optional(bool, false)
    volumes = optional(list(object({
      name = string
      efs = optional(object({
        file_system_id     = string
        root_directory     = optional(string)
        transit_encryption = optional(bool, true)
        access_point_id    = optional(string)
        iam_authorization  = optional(bool, false)
      }))
    })), [])
    containers = list(object({
      name               = string
      image              = string
      essential          = optional(bool, true)
      cpu                = optional(number)
      memory             = optional(number)
      memory_reservation = optional(number)
      port_mappings = optional(list(object({
        container_port = number
        host_port      = optional(number)
        protocol       = optional(string, "tcp")
        name           = optional(string)
        app_protocol   = optional(string)
      })), [])
      environment = optional(map(string), {})
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
    tags = optional(map(string), {})
  }))
  default = {}
}
