variable "name" {
  description = "(Required) Specifies the name of the Container App. Changing this forces a new resource to be created. Must be 2-32 characters using lowercase alphanumerics and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,30}[a-z0-9]$", var.name))
    error_message = "The Container App name must be between 2 and 32 characters, begin and end with an alphanumeric character, and contain only lowercase alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group in which the Container App should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "container_app_environment_id" {
  description = "(Required) The ID of the Container App Managed Environment within which this Container App should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "revision_mode" {
  description = "(Required) The revisions operational mode for the Container App. Possible values are Single and Multiple."
  type        = string

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be either 'Single' or 'Multiple'."
  }
}

variable "template" {
  description = "(Required) A template block configuring the container(s), scaling, and volume mounts."
  type = object({
    containers = list(object({
      name    = string
      image   = string
      cpu     = number
      memory  = string
      args    = optional(list(string), [])
      command = optional(list(string), [])
      env = optional(list(object({
        name        = string
        value       = optional(string, null)
        secret_name = optional(string, null)
      })), [])
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string, null)
      })), [])
      liveness_probe = optional(object({
        transport               = string
        port                    = number
        path                    = optional(string, null)
        initial_delay           = optional(number, 1)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }), null)
      readiness_probe = optional(object({
        transport               = string
        port                    = number
        path                    = optional(string, null)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
        success_count_threshold = optional(number, 1)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }), null)
      startup_probe = optional(object({
        transport               = string
        port                    = number
        path                    = optional(string, null)
        interval_seconds        = optional(number, 10)
        timeout                 = optional(number, 1)
        failure_count_threshold = optional(number, 3)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }), null)
    }))
    init_containers = optional(list(object({
      name    = string
      image   = string
      cpu     = optional(number, 0.25)
      memory  = optional(string, "0.5Gi")
      args    = optional(list(string), [])
      command = optional(list(string), [])
      env = optional(list(object({
        name        = string
        value       = optional(string, null)
        secret_name = optional(string, null)
      })), [])
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string, null)
      })), [])
    })), [])
    min_replicas    = optional(number, 0)
    max_replicas    = optional(number, 10)
    revision_suffix = optional(string, null)
    volumes = optional(list(object({
      name         = string
      storage_name = optional(string, null)
      storage_type = optional(string, "EmptyDir")
    })), [])
    http_scale_rules = optional(list(object({
      name                = string
      concurrent_requests = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    tcp_scale_rules = optional(list(object({
      name                = string
      concurrent_requests = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    custom_scale_rules = optional(list(object({
      name             = string
      custom_rule_type = string
      metadata         = map(string)
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    azure_queue_scale_rules = optional(list(object({
      name         = string
      queue_name   = string
      queue_length = number
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
  })
}

variable "workload_profile_name" {
  description = "(Optional) The name of the Workload Profile in the Container App Environment where this Container App should be placed. Defaults to null (Consumption)."
  type        = string
  default     = null
}

variable "ingress" {
  description = "(Optional) An ingress block configuring external or internal access to the Container App. Defaults to null."
  type = object({
    target_port                = number
    external_enabled           = optional(bool, false)
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    exposed_port               = optional(number, null)
    traffic_weight = optional(list(object({
      percentage      = number
      label           = optional(string, null)
      latest_revision = optional(bool, true)
      revision_suffix = optional(string, null)
    })), [
      {
        percentage      = 100
        latest_revision = true
      }
    ])
    ip_security_restriction = optional(list(object({
      name             = string
      ip_address_range = string
      action           = string
      description      = optional(string, null)
    })), [])
  })
  default = null
}

variable "identity" {
  description = "(Optional) Managed Identity block to assign to the Container App. Defaults to null."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "secrets" {
  description = "(Optional) A list of secrets available to the Container App. Defaults to []."
  type = list(object({
    name                = string
    value               = optional(string, null)
    identity            = optional(string, null)
    key_vault_secret_id = optional(string, null)
  }))
  default   = []
  sensitive = true
}

variable "registries" {
  description = "(Optional) A list of container registry credential blocks. Defaults to []."
  type = list(object({
    server               = string
    identity             = optional(string, null)
    username             = optional(string, null)
    password_secret_name = optional(string, null)
  }))
  default = []
}

variable "dapr" {
  description = "(Optional) A dapr block to configure Dapr settings for the Container App. Defaults to null."
  type = object({
    app_id       = string
    app_port     = optional(number, null)
    app_protocol = optional(string, "http")
  })
  default = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the Container App. Defaults to {}."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
