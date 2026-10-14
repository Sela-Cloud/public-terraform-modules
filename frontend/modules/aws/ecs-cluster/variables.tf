variable "region" {
  description = "The AWS Region in which the resources will be created."
  type        = string
}

variable "ecs_cluster" {
  description = "ECS clusters, keyed by cluster name."
  type = map(object({
    name                               = string
    container_insights                 = optional(string, "disabled")
    execute_command_logging            = optional(string, "DEFAULT")
    execute_command_log_retention_days = optional(number, 30)
    service_connect_namespace_arn      = optional(string)
    enable_fargate                     = optional(bool, true)
    ec2_capacity_providers = optional(list(object({
      name                           = string
      auto_scaling_group_arn         = string
      managed_scaling                = optional(bool, true)
      target_capacity                = optional(number, 100)
      managed_termination_protection = optional(bool, false)
      managed_draining               = optional(bool, true)
    })), [])
    default_capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = optional(number, 1)
      base              = optional(number, 0)
    })), [{ capacity_provider = "FARGATE", weight = 1, base = 0 }])
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for c in values(var.ecs_cluster) :
      length(distinct([for cp in c.ec2_capacity_providers : cp.name])) == length(c.ec2_capacity_providers)
    ])
    error_message = "EC2 capacity provider names must be unique within a cluster."
  }
}
