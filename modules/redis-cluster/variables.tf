variable "project_id" {
  description = "Project where the cluster is created."
  type        = string
}

variable "name" {
  description = "Name of the cluster."
  type        = string
}

variable "region" {
  description = "Region the cluster sits in."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the cluster."
  type        = map(string)
  default     = {}
}

variable "shard_count" {
  description = "Number of shards for the cluster."
  type        = number

  validation {
    condition     = var.shard_count >= 1 && var.shard_count <= 125
    error_message = "shard_count must be between 1 and 125."
  }
}

variable "replica_count" {
  description = "Number of replica nodes per shard."
  type        = number
  default     = 1
}

variable "node_type" {
  description = "The node type for the cluster."
  type        = string
  default     = "REDIS_HIGHMEM_MEDIUM"

  validation {
    condition = contains([
      "REDIS_SHARED_CORE_NANO", "REDIS_HIGHMEM_MEDIUM", "REDIS_HIGHCPU_MEDIUM",
      "REDIS_STANDARD_LARGE", "REDIS_HIGHMEM_XLARGE", "REDIS_HIGHMEM_2XLARGE", "REDIS_STANDARD_SMALL"
    ], var.node_type)
    error_message = "node_type must be one of the documented Redis Cluster node types."
  }
}

variable "zone_distribution_config_mode" {
  description = "MULTI_ZONE or SINGLE_ZONE."
  type        = string
  default     = "MULTI_ZONE"

  validation {
    condition     = contains(["MULTI_ZONE", "SINGLE_ZONE"], var.zone_distribution_config_mode)
    error_message = "zone_distribution_config_mode must be 'MULTI_ZONE' or 'SINGLE_ZONE'."
  }
}

variable "zone_distribution_config_zone" {
  description = "The zone to pin the cluster to. Only used when zone_distribution_config_mode is SINGLE_ZONE."
  type        = string
  default     = null
}

variable "network" {
  description = "The consumer VPC network for the cluster's PSC endpoint."
  type        = string
}

variable "authorization_mode" {
  description = "AUTH_MODE_DISABLED or AUTH_MODE_IAM_AUTH."
  type        = string
  default     = "AUTH_MODE_DISABLED"

  validation {
    condition     = contains(["AUTH_MODE_DISABLED", "AUTH_MODE_IAM_AUTH"], var.authorization_mode)
    error_message = "authorization_mode must be 'AUTH_MODE_DISABLED' or 'AUTH_MODE_IAM_AUTH'."
  }
}

variable "transit_encryption_mode" {
  description = "TRANSIT_ENCRYPTION_MODE_DISABLED or TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION."
  type        = string
  default     = "TRANSIT_ENCRYPTION_MODE_DISABLED"

  validation {
    condition = contains([
      "TRANSIT_ENCRYPTION_MODE_DISABLED", "TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION"
    ], var.transit_encryption_mode)
    error_message = "transit_encryption_mode must be 'TRANSIT_ENCRYPTION_MODE_DISABLED' or 'TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION'."
  }
}

variable "kms_key" {
  description = "Customer-managed encryption key for the cluster's at-rest data."
  type        = string
  default     = null
}

variable "deletion_protection_enabled" {
  description = "If true, deletion of the cluster will fail."
  type        = bool
  default     = true
}

variable "persistence_mode" {
  description = "DISABLED, RDB, or AOF. Leave unset to use the API default (DISABLED)."
  type        = string
  default     = null

  validation {
    condition     = var.persistence_mode == null || contains(["DISABLED", "RDB", "AOF"], var.persistence_mode)
    error_message = "persistence_mode must be 'DISABLED', 'RDB', or 'AOF'."
  }
}

variable "rdb_snapshot_period" {
  description = "ONE_HOUR, SIX_HOURS, TWELVE_HOURS, or TWENTY_FOUR_HOURS. Only used when persistence_mode is RDB."
  type        = string
  default     = null
}

variable "rdb_snapshot_start_time" {
  description = "RFC3339 UTC timestamp that future RDB snapshots are aligned to. Only used when persistence_mode is RDB."
  type        = string
  default     = null
}

variable "aof_append_fsync" {
  description = "NO, EVERYSEC, or ALWAYS. Only used when persistence_mode is AOF."
  type        = string
  default     = null
}

variable "enable_automated_backups" {
  description = "If true, take automated daily backups of the cluster."
  type        = bool
  default     = false
}

variable "automated_backup_retention" {
  description = "How long to keep automated backups, as a duration such as '259200s'. Required when enable_automated_backups is true."
  type        = string
  default     = null
}

variable "automated_backup_start_hour" {
  description = "Hour of day (0-23) the automated backup window starts. Required when enable_automated_backups is true."
  type        = number
  default     = null
}

variable "set_maintenance_window" {
  description = "If true, restrict maintenance updates to a specific weekly window instead of allowing them any day."
  type        = bool
  default     = false
}

variable "maintenance_day" {
  description = "Day of week for the maintenance window. Required when set_maintenance_window is true."
  type        = string
  default     = null
}

variable "maintenance_start_hour" {
  description = "Hour of day (0-23) the maintenance window starts. Required when set_maintenance_window is true."
  type        = number
  default     = null
}

variable "redis_configs" {
  description = "Native Redis configuration parameters (e.g. maxmemory-policy)."
  type        = map(string)
  default     = {}
}
