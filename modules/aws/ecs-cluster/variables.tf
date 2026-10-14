variable "name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "container_insights" {
  description = "CloudWatch Container Insights: 'disabled', 'enabled', or 'enhanced' (adds task- and container-level metrics, at extra cost)."
  type        = string
  default     = "disabled"

  validation {
    condition     = contains(["disabled", "enabled", "enhanced"], var.container_insights)
    error_message = "container_insights must be 'disabled', 'enabled' or 'enhanced'."
  }
}

variable "execute_command_logging" {
  description = "Where ECS Exec session output goes: 'DEFAULT' (the task's own log configuration), 'NONE', or 'OVERRIDE' (a log group this module creates at /ecs/<name>/exec)."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "NONE", "OVERRIDE"], var.execute_command_logging)
    error_message = "execute_command_logging must be 'DEFAULT', 'NONE' or 'OVERRIDE'."
  }
}

variable "execute_command_log_retention_days" {
  description = "Retention of the ECS Exec log group when execute_command_logging is 'OVERRIDE'. 0 keeps logs forever."
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.execute_command_log_retention_days)
    error_message = "execute_command_log_retention_days must be one of the values CloudWatch Logs accepts, such as 7, 14, 30, 90, 365, or 0 for forever."
  }
}

variable "service_connect_namespace_arn" {
  description = "ARN of a Cloud Map HTTP namespace (the ecs-service-connect module) that services in this cluster join by default. Null for none."
  type        = string
  default     = null
}

variable "enable_fargate" {
  description = "Register the FARGATE and FARGATE_SPOT capacity providers with the cluster."
  type        = bool
  default     = true
}

variable "ec2_capacity_providers" {
  description = "Capacity providers backed by existing Auto Scaling Groups, keyed by name. The ASG's instances must run an ECS-optimised AMI that joins this cluster (ECS_CLUSTER in user data)."
  type = map(object({
    name                   = string
    auto_scaling_group_arn = string
    managed_scaling        = optional(bool, true)
    # Percentage of the ASG's capacity ECS aims to use; 100 packs instances fully.
    target_capacity = optional(number, 100)
    # Requires scale-in protection on the ASG; off by default because most ASGs do not set it.
    managed_termination_protection = optional(bool, false)
    managed_draining               = optional(bool, true)
  }))
  default = {}

  validation {
    condition = alltrue([
      for cp in values(var.ec2_capacity_providers) :
      !can(regex("^(?i)(aws|ecs|fargate)", cp.name))
    ])
    error_message = "ec2_capacity_providers names cannot start with 'aws', 'ecs' or 'fargate' — AWS reserves those prefixes."
  }

  validation {
    condition = alltrue([
      for cp in values(var.ec2_capacity_providers) : cp.target_capacity >= 1 && cp.target_capacity <= 100
    ])
    error_message = "ec2_capacity_providers target_capacity must be between 1 and 100."
  }
}

variable "default_capacity_provider_strategy" {
  description = "How services that set no strategy of their own spread tasks across capacity providers. Each capacity_provider is FARGATE, FARGATE_SPOT, or an ec2_capacity_providers name. Empty sets no default."
  type = list(object({
    capacity_provider = string
    weight            = optional(number, 1)
    base              = optional(number, 0)
  }))
  default = [{ capacity_provider = "FARGATE", weight = 1, base = 0 }]

  validation {
    condition     = length([for s in var.default_capacity_provider_strategy : s if s.base > 0]) <= 1
    error_message = "Only one capacity provider in default_capacity_provider_strategy can have a base above 0."
  }

  validation {
    condition = alltrue([
      for s in var.default_capacity_provider_strategy : s.weight >= 0 && s.weight <= 1000 && s.base >= 0 && s.base <= 100000
    ])
    error_message = "default_capacity_provider_strategy weight must be 0-1000 and base 0-100000."
  }
}

variable "tags" {
  description = "Tags applied to the cluster and everything this module creates."
  type        = map(string)
  default     = {}
}
