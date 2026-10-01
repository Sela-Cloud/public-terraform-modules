variable "name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the PostgreSQL Flexible Server should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the PostgreSQL Flexible Server should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "administrator_login" {
  description = "(Optional) The Administrator login for the PostgreSQL Flexible Server. Required when create_mode is Default."
  type        = string
  default     = "pgadmin"
}

variable "administrator_password" {
  description = "(Optional) The Password associated with the administrator_login. Required when create_mode is Default."
  type        = string
  default     = null
  sensitive   = true
}

variable "sku_name" {
  description = "(Optional) The SKU Name for the PostgreSQL Flexible Server. Defaults to B_Standard_B1ms."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "server_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use. Possible values are 11, 12, 13, 14, 15, and 16. Defaults to 16."
  type        = string
  default     = "16"
}

variable "storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server in megabytes. Defaults to 32768 (32GB)."
  type        = number
  default     = 32768
}

variable "storage_tier" {
  description = "(Optional) The name of storage tier for the PostgreSQL Flexible Server. (e.g. P4, P6, P10, P15, P20, P30)."
  type        = string
  default     = null
}

variable "auto_grow_enabled" {
  description = "(Optional) Should storage auto-grow be enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "(Optional) The backup retention days for the PostgreSQL Flexible Server. Possible values are between 7 and 35 days. Defaults to 7."
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "(Optional) Should geo-redundant backup be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "delegated_subnet_id" {
  description = "(Optional) The ID of the virtual network subnet to create the PostgreSQL Flexible Server in."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "(Optional) The ID of the private DNS zone for the PostgreSQL Flexible Server. Required when delegated_subnet_id is set."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether or not public network access is allowed for this server. Defaults to true."
  type        = bool
  default     = true
}

variable "zone" {
  description = "(Optional) Specifies the Availability Zone in which the PostgreSQL Flexible Server should be located."
  type        = string
  default     = null
}

variable "create_mode" {
  description = "(Optional) The creation mode. Can be Default, PointInTimeRestore, GeoRestore, or Replica. Defaults to Default."
  type        = string
  default     = "Default"
}

variable "point_in_time_restore_time_in_utc" {
  description = "(Optional) Point in time restore time in UTC (RFC3339 format) when create_mode is PointInTimeRestore."
  type        = string
  default     = null
}

variable "source_server_id" {
  description = "(Optional) The resource ID of the source server when create_mode is PointInTimeRestore, GeoRestore, or Replica."
  type        = string
  default     = null
}

variable "replication_role" {
  description = "(Optional) The replication role for the PostgreSQL Flexible Server. Possible values are None and Primary."
  type        = string
  default     = null
}

variable "high_availability" {
  description = "(Optional) High availability configuration block."
  type = object({
    mode                      = string
    standby_availability_zone = optional(string, null)
  })
  default = null
}

variable "maintenance_window" {
  description = "(Optional) Maintenance window configuration block."
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = null
}

variable "authentication" {
  description = "(Optional) Authentication configuration block for Azure Active Directory / Entra."
  type = object({
    active_directory_auth_enabled = optional(bool, false)
    password_auth_enabled         = optional(bool, true)
    tenant_id                     = optional(string, null)
  })
  default = null
}

variable "identity" {
  description = "(Optional) Managed identity configuration block."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "databases" {
  description = "(Optional) Map of databases to create on the PostgreSQL Flexible Server."
  type = map(object({
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  default = {}
}

variable "firewall_rules" {
  description = "(Optional) Map of firewall rules to create on the PostgreSQL Flexible Server."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "server_parameters" {
  description = "(Optional) Map of server parameters / configurations to set on the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
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
