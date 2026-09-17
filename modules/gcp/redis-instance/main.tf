resource "google_redis_instance" "this" {
  project                 = var.project_id
  name                    = var.name
  display_name            = var.display_name
  region                  = var.region
  labels                  = var.labels
  tier                    = var.tier
  memory_size_gb          = var.memory_size_gb
  location_id             = var.tier == "BASIC" ? var.location_id : null
  read_replicas_mode      = var.enable_read_replicas ? "READ_REPLICAS_ENABLED" : null
  replica_count           = var.enable_read_replicas ? var.replica_count : null
  secondary_ip_range      = var.enable_read_replicas ? var.secondary_ip_range : null
  authorized_network      = var.network
  connect_mode            = var.connect_mode
  reserved_ip_range       = var.reserved_ip_range
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode
  customer_managed_key    = var.customer_managed_key
  deletion_protection     = var.deletion_protection
  redis_version           = var.redis_version
  redis_configs           = var.redis_configs

  dynamic "persistence_config" {
    for_each = var.persistence_mode == null ? [] : [""]
    content {
      persistence_mode        = var.persistence_mode
      rdb_snapshot_period     = var.persistence_mode == "RDB" ? var.rdb_snapshot_period : null
      rdb_snapshot_start_time = var.persistence_mode == "RDB" ? var.rdb_snapshot_start_time : null
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.set_maintenance_window ? [""] : []
    content {
      weekly_maintenance_window {
        day = var.maintenance_day
        start_time {
          hours = var.maintenance_start_hour
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.tier == "BASIC" || var.location_id == null
      error_message = "location_id is only used when tier is BASIC."
    }
    precondition {
      condition     = var.tier == "STANDARD_HA" || !var.enable_read_replicas
      error_message = "enable_read_replicas requires tier to be STANDARD_HA."
    }
    precondition {
      condition     = !var.enable_read_replicas || (var.replica_count != null && var.secondary_ip_range != null)
      error_message = "replica_count and secondary_ip_range are required when enable_read_replicas is true."
    }
    precondition {
      condition     = !var.enable_read_replicas || !contains(["REDIS_3_2", "REDIS_4_0"], var.redis_version)
      error_message = "redis_version must be 5.0 or higher when enable_read_replicas is true."
    }
    precondition {
      condition     = var.persistence_mode != "RDB" || (var.rdb_snapshot_period != null && var.rdb_snapshot_start_time != null)
      error_message = "rdb_snapshot_period and rdb_snapshot_start_time are required when persistence_mode is RDB."
    }
    precondition {
      condition     = !var.set_maintenance_window || (var.maintenance_day != null && var.maintenance_start_hour != null)
      error_message = "maintenance_day and maintenance_start_hour are required when set_maintenance_window is true."
    }
  }
}
