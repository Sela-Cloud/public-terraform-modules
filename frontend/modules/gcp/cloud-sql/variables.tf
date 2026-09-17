variable "project_id" {
  type = string
}

variable "cloud_sql" {
  type = map(object({
    name                                          = string
    engine                                        = string
    region                                        = string
    database_version                              = string
    edition                                       = string
    tier                                          = string
    availability_type                             = optional(string, "ZONAL")
    disk_type                                     = optional(string, "PD_SSD")
    disk_size                                     = optional(number)
    disk_autoresize                               = optional(bool, true)
    disk_autoresize_limit                         = optional(number, 0)
    ipv4_enabled                                  = optional(bool, false)
    private_network                               = optional(string)
    allocated_ip_range                            = optional(string)
    enable_private_path_for_google_cloud_services = optional(bool, false)
    ssl_mode                                      = optional(string, "ENCRYPTED_ONLY")
    authorized_networks = optional(map(object({
      name            = optional(string)
      value           = string
      expiration_time = optional(string)
    })), {})
    deletion_protection            = optional(bool, true)
    deletion_protection_enabled    = optional(bool, true)
    connector_enforcement          = optional(string)
    backup_enabled                 = optional(bool, true)
    backup_start_time              = optional(string)
    backup_location                = optional(string)
    binary_log_enabled             = optional(bool, false)
    point_in_time_recovery_enabled = optional(bool, false)
    transaction_log_retention_days = optional(number)
    retained_backups               = optional(number, 7)
    maintenance_day                = optional(string)
    maintenance_hour               = optional(number)
    maintenance_update_track       = optional(string, "stable")
    query_insights_enabled         = optional(bool, true)
    query_string_length            = optional(number, 1024)
    query_plans_per_minute         = optional(number, 5)
    record_application_tags        = optional(bool, true)
    record_client_address          = optional(bool, false)
    database_flags = optional(map(object({
      name  = string
      value = string
    })), {})
    password_validation_policy = optional(object({
      enabled                     = optional(bool, true)
      min_length                  = optional(number, 12)
      complexity                  = optional(string, "COMPLEXITY_DEFAULT")
      reuse_interval              = optional(number)
      disallow_username_substring = optional(bool, true)
      password_change_interval    = optional(string)
    }))
    databases = optional(list(object({
      name            = string
      charset         = optional(string)
      collation       = optional(string)
      deletion_policy = optional(string, "ABANDON")
    })), [])
    iam_users = optional(list(object({
      name            = string
      type            = string
      iam_member      = string
      deletion_policy = optional(string, "ABANDON")
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      can(regex("^(POSTGRES|MYSQL)_", instance.database_version))
    ])
    error_message = "Cloud SQL Phase 1 supports PostgreSQL and MySQL database versions only."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.ipv4_enabled || try(trimspace(instance.private_network), "") != ""
    ])
    error_message = "Every Cloud SQL instance must enable public IPv4 or select a private VPC network."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.availability_type != "REGIONAL" || (
        instance.backup_enabled && (
          startswith(instance.database_version, "MYSQL_") ? instance.binary_log_enabled : instance.point_in_time_recovery_enabled
        )
      )
    ])
    error_message = "Regional Cloud SQL availability requires backups and MySQL binary logging or PostgreSQL point-in-time recovery."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.edition == "ENTERPRISE" || instance.edition == "ENTERPRISE_PLUS"
    ])
    error_message = "Cloud SQL edition must be ENTERPRISE or ENTERPRISE_PLUS."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.edition != "ENTERPRISE_PLUS" || can(regex("^(db-perf-optimized-N-|db-c4a-)", instance.tier))
    ])
    error_message = "Enterprise Plus requires an N2 db-perf-optimized-N-* or C4A db-c4a-* machine tier."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.edition != "ENTERPRISE" || !can(regex("^(db-perf-optimized-N-|db-c4a-)", instance.tier))
    ])
    error_message = "N2 db-perf-optimized-N-* and C4A db-c4a-* machine tiers require Enterprise Plus."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      !startswith(instance.tier, "db-c4a-") || instance.disk_type == "HYPERDISK_BALANCED"
    ])
    error_message = "C4A Cloud SQL machine tiers require HYPERDISK_BALANCED storage."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      !startswith(instance.tier, "db-perf-optimized-N-") || instance.disk_type == "PD_SSD"
    ])
    error_message = "N2 Cloud SQL machine tiers require PD_SSD storage."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.transaction_log_retention_days == null || (
        instance.transaction_log_retention_days >= 1 &&
        instance.transaction_log_retention_days <= (instance.edition == "ENTERPRISE_PLUS" ? 35 : 7)
      )
    ])
    error_message = "Transaction-log retention must be 1-7 days for Enterprise or 1-35 days for Enterprise Plus."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.query_string_length >= (instance.edition == "ENTERPRISE_PLUS" ? 1024 : 256) &&
      instance.query_string_length <= (instance.edition == "ENTERPRISE_PLUS" ? 100000 : 4500)
    ])
    error_message = "Query Insights query length must be 256-4500 bytes for Enterprise or 1024-100000 bytes for Enterprise Plus."
  }

  validation {
    condition = alltrue([
      for instance in values(var.cloud_sql) :
      instance.query_plans_per_minute >= 0 &&
      instance.query_plans_per_minute <= (instance.edition == "ENTERPRISE_PLUS" ? 200 : 20)
    ])
    error_message = "Query Insights plans per minute must be 0-20 for Enterprise or 0-200 for Enterprise Plus."
  }

  validation {
    condition = alltrue(flatten([
      for instance in values(var.cloud_sql) : [
        for user in instance.iam_users : contains(["CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT"], user.type)
      ]
    ]))
    error_message = "Cloud SQL Phase 1 supports CLOUD_IAM_USER and CLOUD_IAM_SERVICE_ACCOUNT users only."
  }

  validation {
    condition = alltrue(flatten([
      for instance in values(var.cloud_sql) : [
        for user in instance.iam_users :
        instance.engine != "mysql" || (!strcontains(user.name, "@") && length(user.name) <= 32)
      ]
    ]))
    error_message = "MySQL IAM database usernames must be the local email part only, without @domain, and must not exceed 32 characters."
  }
}
