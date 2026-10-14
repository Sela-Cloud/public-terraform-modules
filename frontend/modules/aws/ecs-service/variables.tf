variable "region" {
  description = "The AWS Region in which the resources will be created."
  type        = string
}

variable "ecs_service" {
  description = "ECS services, keyed by service name."
  type = map(object({
    name            = string
    cluster         = string
    task_definition = string
    desired_count   = optional(number, 1)
    launch_type     = optional(string)
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = optional(number, 1)
      base              = optional(number, 0)
    })), [])
    subnet_ids         = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    assign_public_ip   = optional(bool, false)
    load_balancers = optional(list(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })), [])
    health_check_grace_period_seconds  = optional(number, 60)
    deployment_minimum_healthy_percent = optional(number, 100)
    deployment_maximum_percent         = optional(number, 200)
    deployment_circuit_breaker = optional(object({
      enable   = optional(bool, true)
      rollback = optional(bool, true)
    }), {})
    availability_zone_rebalancing = optional(string, "ENABLED")
    enable_execute_command        = optional(bool, false)
    propagate_tags                = optional(string, "SERVICE")
    force_new_deployment          = optional(bool, false)
    wait_for_steady_state         = optional(bool, false)
    service_connect = optional(object({
      enabled   = optional(bool, false)
      namespace = optional(string)
      services = optional(list(object({
        port_name             = string
        discovery_name        = optional(string)
        client_alias_port     = number
        client_alias_dns_name = optional(string)
      })), [])
    }), {})
    autoscaling = optional(object({
      enabled      = optional(bool, false)
      min_capacity = optional(number, 1)
      max_capacity = optional(number, 4)
      policies = optional(list(object({
        name               = string
        metric             = string
        target_value       = number
        resource_label     = optional(string)
        scale_in_cooldown  = optional(number, 300)
        scale_out_cooldown = optional(number, 60)
        disable_scale_in   = optional(bool, false)
      })), [])
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
