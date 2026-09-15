variable "project_id" {
  type = string
}

variable "redis_instance" {
  description = "Memorystore for Redis instances configured through the Sela Deployer catalog."

  type = map(object({
    name                    = string
    display_name            = optional(string)
    region                  = string
    labels                  = optional(map(string), {})
    tier                    = optional(string, "BASIC")
    memory_size_gb          = number
    location_id             = optional(string)
    enable_read_replicas    = optional(bool, false)
    replica_count           = optional(number)
    secondary_ip_range      = optional(string)
    network                 = string
    connect_mode            = optional(string, "DIRECT_PEERING")
    reserved_ip_range       = optional(string)
    auth_enabled            = optional(bool, false)
    transit_encryption_mode = optional(string, "DISABLED")
    customer_managed_key    = optional(string)
    deletion_protection     = optional(bool, false)
    redis_version           = optional(string, "REDIS_7_2")
    persistence_mode        = optional(string)
    rdb_snapshot_period     = optional(string)
    rdb_snapshot_start_time = optional(string)
    set_maintenance_window  = optional(bool, false)
    maintenance_day         = optional(string)
    maintenance_start_hour  = optional(number)
    redis_configs           = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) : i.memory_size_gb >= 1 && i.memory_size_gb <= 300
    ])
    error_message = "memory_size_gb must be between 1 and 300."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) : i.tier == "BASIC" || i.location_id == null
    ])
    error_message = "location_id is only used when tier is BASIC."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) : i.tier == "STANDARD_HA" || !i.enable_read_replicas
    ])
    error_message = "enable_read_replicas requires tier to be STANDARD_HA."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) :
      !i.enable_read_replicas || (i.replica_count != null && i.secondary_ip_range != null)
    ])
    error_message = "replica_count and secondary_ip_range are required when enable_read_replicas is true."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) :
      !i.enable_read_replicas || !contains(["REDIS_3_2", "REDIS_4_0"], i.redis_version)
    ])
    error_message = "redis_version must be 5.0 or higher when enable_read_replicas is true."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) :
      i.persistence_mode != "RDB" || (i.rdb_snapshot_period != null && i.rdb_snapshot_start_time != null)
    ])
    error_message = "rdb_snapshot_period and rdb_snapshot_start_time are required when persistence_mode is RDB."
  }

  validation {
    condition = alltrue([
      for i in values(var.redis_instance) :
      !i.set_maintenance_window || (i.maintenance_day != null && i.maintenance_start_hour != null)
    ])
    error_message = "maintenance_day and maintenance_start_hour are required when set_maintenance_window is true."
  }
}
