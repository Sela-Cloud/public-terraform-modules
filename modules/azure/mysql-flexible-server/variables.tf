variable "name" {
  description = "(Required) Specifies the name of the MySQL Flexible Server. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which the MySQL Flexible Server should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region in which the MySQL Flexible Server should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "administrator_login" {
  description = "(Optional) The Administrator login for the MySQL Flexible Server. Required when create_mode is Default."
  type        = string
  default     = "mysqladmin"
}

variable "administrator_password" {
  description = "(Optional) The Password associated with the administrator_login for the MySQL Flexible Server. Required when create_mode is Default."
  type        = string
  default     = null
  sensitive   = true
}

variable "sku_name" {
  description = "(Optional) The SKU name for the MySQL Flexible Server. Defaults to B_Standard_B1ms."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "server_version" {
  description = "(Optional) The version of the MySQL Flexible Server. Possible values are 5.7 and 8.0.21. Defaults to 8.0.21."
  type        = string
  default     = "8.0.21"
}

variable "storage" {
  description = "(Optional) Storage configuration block for the MySQL Flexible Server."
  type = object({
    size_gb            = optional(number, 20)
    iops               = optional(number, 360)
    auto_grow_enabled  = optional(bool, true)
    io_scaling_enabled = optional(bool, false)
  })
  default = {
    size_gb            = 20
    iops               = 360
    auto_grow_enabled  = true
    io_scaling_enabled = false
  }
}

variable "high_availability" {
  description = "(Optional) High availability configuration block for the MySQL Flexible Server."
  type = object({
    mode                      = string
    standby_availability_zone = optional(string, null)
  })
  default = null
}

variable "maintenance_window" {
  description = "(Optional) Maintenance window configuration for the MySQL Flexible Server."
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
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

variable "backup_retention_days" {
  description = "(Optional) The backup retention days for the MySQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7."
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "(Optional) Should geo-redundant backup be enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "delegated_subnet_id" {
  description = "(Optional) The ID of the virtual network subnet to create the MySQL Flexible Server in. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "(Optional) The ID of the private DNS zone for the MySQL Flexible Server. Required when delegated_subnet_id is set."
  type        = string
  default     = null
}

variable "public_network_access" {
  description = "(Optional) Specifies whether public network access is allowed for this server. Possible values are Enabled and Disabled. Defaults to Enabled."
  type        = string
  default     = "Enabled"
}

variable "zone" {
  description = "(Optional) Specifies the Availability Zone in which this MySQL Flexible Server should be located."
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
  description = "(Optional) The replication role. Possible value is None."
  type        = string
  default     = null
}

variable "databases" {
  description = "(Optional) Map of databases to create on the MySQL Flexible Server."
  type = map(object({
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
  }))
  default = {}
}

variable "firewall_rules" {
  description = "(Optional) Map of firewall rules to create on the MySQL Flexible Server."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "server_parameters" {
  description = "(Optional) Map of server configurations / parameters to set on the MySQL Flexible Server."
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
