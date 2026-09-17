resource "google_redis_cluster" "this" {
  project                     = var.project_id
  name                        = var.name
  region                      = var.region
  labels                      = var.labels
  shard_count                 = var.shard_count
  replica_count               = var.replica_count
  node_type                   = var.node_type
  authorization_mode          = var.authorization_mode
  transit_encryption_mode     = var.transit_encryption_mode
  kms_key                     = var.kms_key
  deletion_protection_enabled = var.deletion_protection_enabled
  redis_configs               = var.redis_configs

  psc_configs {
    network = var.network
  }

  zone_distribution_config {
    mode = var.zone_distribution_config_mode
    zone = var.zone_distribution_config_mode == "SINGLE_ZONE" ? var.zone_distribution_config_zone : null
  }

  dynamic "persistence_config" {
    for_each = var.persistence_mode == null ? [] : [""]
    content {
      mode = var.persistence_mode

      dynamic "rdb_config" {
        for_each = var.persistence_mode == "RDB" ? [""] : []
        content {
          rdb_snapshot_period     = var.rdb_snapshot_period
          rdb_snapshot_start_time = var.rdb_snapshot_start_time
        }
      }

      dynamic "aof_config" {
        for_each = var.persistence_mode == "AOF" ? [""] : []
        content {
          append_fsync = var.aof_append_fsync
        }
      }
    }
  }

  dynamic "automated_backup_config" {
    for_each = var.enable_automated_backups ? [""] : []
    content {
      retention = var.automated_backup_retention
      fixed_frequency_schedule {
        start_time {
          hours = var.automated_backup_start_hour
        }
      }
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
      condition     = var.zone_distribution_config_mode == "SINGLE_ZONE" || var.zone_distribution_config_zone == null
      error_message = "zone_distribution_config_zone is only used when zone_distribution_config_mode is SINGLE_ZONE."
    }
    precondition {
      condition     = var.zone_distribution_config_mode != "SINGLE_ZONE" || var.zone_distribution_config_zone != null
      error_message = "zone_distribution_config_zone is required when zone_distribution_config_mode is SINGLE_ZONE."
    }
    precondition {
      condition     = var.persistence_mode != "RDB" || (var.rdb_snapshot_period != null && var.rdb_snapshot_start_time != null)
      error_message = "rdb_snapshot_period and rdb_snapshot_start_time are required when persistence_mode is RDB."
    }
    precondition {
      condition     = var.persistence_mode != "AOF" || var.aof_append_fsync != null
      error_message = "aof_append_fsync is required when persistence_mode is AOF."
    }
    precondition {
      condition     = !var.enable_automated_backups || (var.automated_backup_retention != null && var.automated_backup_start_hour != null)
      error_message = "automated_backup_retention and automated_backup_start_hour are required when enable_automated_backups is true."
    }
    precondition {
      condition     = !var.set_maintenance_window || (var.maintenance_day != null && var.maintenance_start_hour != null)
      error_message = "maintenance_day and maintenance_start_hour are required when set_maintenance_window is true."
    }
  }
}
