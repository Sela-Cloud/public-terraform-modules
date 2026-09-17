data "google_compute_network" "private" {
  count   = var.private_network == null ? 0 : 1
  project = var.project_id
  name    = var.private_network
}

resource "google_sql_database_instance" "this" {
  project          = var.project_id
  name             = var.name
  region           = var.region
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  # Cloud SQL can grow a disk automatically but cannot shrink it. Keep the
  # provider from trying to reconcile the resulting size back on later applies.
  lifecycle {
    ignore_changes = [settings[0].disk_size]
  }

  settings {
    tier                        = var.tier
    edition                     = var.edition
    availability_type           = var.availability_type
    disk_type                   = var.disk_type
    disk_size                   = var.disk_autoresize ? null : var.disk_size
    disk_autoresize             = var.disk_autoresize
    disk_autoresize_limit       = var.disk_autoresize_limit
    deletion_protection_enabled = var.deletion_protection_enabled
    connector_enforcement       = var.connector_enforcement

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = try(data.google_compute_network.private[0].self_link, null)
      allocated_ip_range                            = var.allocated_ip_range
      enable_private_path_for_google_cloud_services = var.enable_private_path_for_google_cloud_services
      ssl_mode                                      = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = var.ipv4_enabled ? var.authorized_networks : {}
        content {
          name            = authorized_networks.value.name
          value           = authorized_networks.value.value
          expiration_time = authorized_networks.value.expiration_time
        }
      }
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      location                       = var.backup_location
      binary_log_enabled             = var.binary_log_enabled
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    dynamic "maintenance_window" {
      for_each = var.maintenance_day == null ? [] : [1]
      content {
        day          = var.maintenance_day
        hour         = var.maintenance_hour
        update_track = var.maintenance_update_track
      }
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = var.query_string_length
      query_plans_per_minute  = var.query_plans_per_minute
      record_application_tags = var.record_application_tags
      record_client_address   = var.record_client_address
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "password_validation_policy" {
      for_each = var.password_validation_policy == null ? [] : [var.password_validation_policy]
      content {
        enable_password_policy      = password_validation_policy.value.enabled
        min_length                  = password_validation_policy.value.min_length
        complexity                  = password_validation_policy.value.complexity
        reuse_interval              = password_validation_policy.value.reuse_interval
        disallow_username_substring = password_validation_policy.value.disallow_username_substring
        password_change_interval    = password_validation_policy.value.password_change_interval
      }
    }
  }
}
