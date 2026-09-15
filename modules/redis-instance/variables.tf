variable "project_id" {
  description = "Project where the instance is created."
  type        = string
}

variable "name" {
  description = "Name of the instance."
  type        = string
}

variable "display_name" {
  description = "Arbitrary, optional display name for the instance."
  type        = string
  default     = null
}

variable "region" {
  description = "Region the instance sits in."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the instance."
  type        = map(string)
  default     = {}
}

variable "tier" {
  description = "BASIC (standalone) or STANDARD_HA (primary/replica, supports read replicas)."
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.tier)
    error_message = "tier must be 'BASIC' or 'STANDARD_HA'."
  }
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB."
  type        = number

  validation {
    condition     = var.memory_size_gb >= 1 && var.memory_size_gb <= 300
    error_message = "memory_size_gb must be between 1 and 300."
  }
}

variable "location_id" {
  description = "The zone to provision the instance in. Only used when tier is BASIC."
  type        = string
  default     = null
}

variable "enable_read_replicas" {
  description = "If true, enable read replicas. Only used when tier is STANDARD_HA."
  type        = bool
  default     = false
}

variable "replica_count" {
  description = "Number of replica nodes (1-5). Only used when enable_read_replicas is true."
  type        = number
  default     = null
}

variable "secondary_ip_range" {
  description = "Additional IP range for node placement, or 'auto'. Required when enable_read_replicas is true."
  type        = string
  default     = null
}

variable "network" {
  description = "The VPC network the instance is connected to."
  type        = string
}

variable "connect_mode" {
  description = "DIRECT_PEERING or PRIVATE_SERVICE_ACCESS."
  type        = string
  default     = "DIRECT_PEERING"

  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.connect_mode)
    error_message = "connect_mode must be 'DIRECT_PEERING' or 'PRIVATE_SERVICE_ACCESS'."
  }
}

variable "reserved_ip_range" {
  description = "CIDR range of internal addresses reserved for this instance. Leave unset to let the service choose."
  type        = string
  default     = null
}

variable "auth_enabled" {
  description = "If true, require an AUTH string to connect."
  type        = bool
  default     = false
}

variable "transit_encryption_mode" {
  description = "SERVER_AUTHENTICATION or DISABLED."
  type        = string
  default     = "DISABLED"

  validation {
    condition     = contains(["SERVER_AUTHENTICATION", "DISABLED"], var.transit_encryption_mode)
    error_message = "transit_encryption_mode must be 'SERVER_AUTHENTICATION' or 'DISABLED'."
  }
}

variable "customer_managed_key" {
  description = "Customer-managed encryption key for the instance's at-rest data."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If true, Terraform is prevented from destroying this instance."
  type        = bool
  default     = false
}

variable "redis_version" {
  description = "The version of Redis software."
  type        = string
  default     = "REDIS_7_2"

  validation {
    condition = contains([
      "REDIS_3_2", "REDIS_4_0", "REDIS_5_0", "REDIS_6_X", "REDIS_7_0", "REDIS_7_2"
    ], var.redis_version)
    error_message = "redis_version must be one of the documented Memorystore for Redis versions."
  }
}

variable "persistence_mode" {
  description = "DISABLED or RDB. Leave unset to use the API default (DISABLED)."
  type        = string
  default     = null

  validation {
    condition     = var.persistence_mode == null || contains(["DISABLED", "RDB"], var.persistence_mode)
    error_message = "persistence_mode must be 'DISABLED' or 'RDB'."
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
