variable "project_id" {
  type = string
}

variable "redis_cluster" {
  description = "Memorystore for Redis Cluster instances configured through the Sela Deployer catalog."

  type = map(object({
    name                          = string
    region                        = string
    labels                        = optional(map(string), {})
    shard_count                   = number
    replica_count                 = optional(number, 1)
    node_type                     = optional(string, "REDIS_HIGHMEM_MEDIUM")
    zone_distribution_config_mode = optional(string, "MULTI_ZONE")
    zone_distribution_config_zone = optional(string)
    network                       = string
    authorization_mode            = optional(string, "AUTH_MODE_DISABLED")
    transit_encryption_mode       = optional(string, "TRANSIT_ENCRYPTION_MODE_DISABLED")
    kms_key                       = optional(string)
    deletion_protection_enabled   = optional(bool, true)
    persistence_mode              = optional(string)
    rdb_snapshot_period           = optional(string)
    rdb_snapshot_start_time       = optional(string)
    aof_append_fsync              = optional(string)
    enable_automated_backups      = optional(bool, false)
    automated_backup_retention    = optional(string)
    automated_backup_start_hour   = optional(number)
    set_maintenance_window        = optional(bool, false)
    maintenance_day               = optional(string)
    maintenance_start_hour        = optional(number)
    redis_configs                 = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) : c.shard_count >= 1 && c.shard_count <= 125
    ])
    error_message = "shard_count must be between 1 and 125."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) :
      c.zone_distribution_config_mode == "SINGLE_ZONE" || c.zone_distribution_config_zone == null
    ])
    error_message = "zone_distribution_config_zone is only used when zone_distribution_config_mode is SINGLE_ZONE."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) :
      c.zone_distribution_config_mode != "SINGLE_ZONE" || c.zone_distribution_config_zone != null
    ])
    error_message = "zone_distribution_config_zone is required when zone_distribution_config_mode is SINGLE_ZONE."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) :
      c.persistence_mode != "RDB" || (c.rdb_snapshot_period != null && c.rdb_snapshot_start_time != null)
    ])
    error_message = "rdb_snapshot_period and rdb_snapshot_start_time are required when persistence_mode is RDB."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) : c.persistence_mode != "AOF" || c.aof_append_fsync != null
    ])
    error_message = "aof_append_fsync is required when persistence_mode is AOF."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) :
      !c.enable_automated_backups || (c.automated_backup_retention != null && c.automated_backup_start_hour != null)
    ])
    error_message = "automated_backup_retention and automated_backup_start_hour are required when enable_automated_backups is true."
  }

  validation {
    condition = alltrue([
      for c in values(var.redis_cluster) :
      !c.set_maintenance_window || (c.maintenance_day != null && c.maintenance_start_hour != null)
    ])
    error_message = "maintenance_day and maintenance_start_hour are required when set_maintenance_window is true."
  }
}
