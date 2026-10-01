variable "name" {
  description = "(Required) The name of the SQL Managed Instance. This needs to be globally unique within Azure."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the SQL Managed Instance."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "sku_name" {
  description = "(Required) Specifies the SKU Name for the SQL Managed Instance. Valid values include GP_Gen5, GP_G8IM, GP_G8IH, BC_Gen5, BC_G8IM, BC_G8IH. Defaults to GP_Gen5."
  type        = string
  default     = "GP_Gen5"
}

variable "vcores" {
  description = "(Required) Number of vCores for the SQL Managed Instance. Allowed values are 4, 8, 16, 24, 32, 40, 64, 80. Defaults to 4."
  type        = number
  default     = 4
}

variable "storage_size_in_gb" {
  description = "(Required) Maximum storage space for your instance in Gigabytes. Integer values in increments of 32 between 32 and 16384. Defaults to 32."
  type        = number
  default     = 32
}

variable "subnet_id" {
  description = "(Required) The subnet resource ID that the SQL Managed Instance will be associated with. Must be dedicated and delegated to Microsoft.Sql/managedInstances."
  type        = string
}

variable "license_type" {
  description = "(Required) What type of license the Managed Instance will use. Valid values include LicenseIncluded and BasePrice. Defaults to LicenseIncluded."
  type        = string
  default     = "LicenseIncluded"
}

variable "administrator_login" {
  description = "(Optional) The administrator login name for the new SQL Managed Instance."
  type        = string
  default     = "sqladmin"
}

variable "administrator_login_password" {
  description = "(Optional) The password associated with the administrator_login user."
  type        = string
  default     = null
  sensitive   = true
}

variable "collation" {
  description = "(Optional) Specifies how the SQL Managed Instance will be collated. Defaults to SQL_Latin1_General_CP1_CI_AS."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "timezone_id" {
  description = "(Optional) The ID of the timezone to assign. Defaults to UTC."
  type        = string
  default     = "UTC"
}

variable "minimum_tls_version" {
  description = "(Optional) The Minimum TLS Version for all connections. Valid values are 1.0, 1.1, and 1.2. Defaults to 1.2."
  type        = string
  default     = "1.2"
}

variable "proxy_override" {
  description = "(Optional) Specifies how incoming connections will be routed to the service. Allowed values are Default, Proxy, and Redirect. Defaults to Default."
  type        = string
  default     = "Default"
}

variable "public_data_endpoint_enabled" {
  description = "(Optional) Is the public data endpoint enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "storage_account_type" {
  description = "(Optional) Specifies the storage account type used to store backups for this database. Allowed values are GRS, LRS, and ZRS. Defaults to GRS."
  type        = string
  default     = "GRS"
}

variable "storage_iops" {
  description = "(Optional) The storage IOPS for the SQL Managed Instance."
  type        = number
  default     = null
}

variable "zone_redundant_enabled" {
  description = "(Optional) Specifies whether this SQL Managed Instance is zone redundant? Defaults to false."
  type        = bool
  default     = false
}

variable "dns_zone_partner_id" {
  description = "(Optional) The ID of the SQL Managed Instance which will share the DNS zone."
  type        = string
  default     = null
}

variable "maintenance_configuration_name" {
  description = "(Optional) The name of the Public Maintenance Configuration window."
  type        = string
  default     = null
}

variable "identity" {
  description = "(Optional) Managed service identity block."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "azure_active_directory_administrator" {
  description = "(Optional) Azure Active Directory Administrator block."
  type = object({
    login_username                      = string
    object_id                           = string
    principal_type                      = optional(string, "User")
    tenant_id                           = optional(string, null)
    azuread_authentication_only_enabled = optional(bool, false)
  })
  default = null
}

variable "managed_databases" {
  description = "(Optional) Map of databases to create on the Managed Instance."
  type = map(object({
    short_term_retention_days = optional(number, 7)
    tags                      = optional(map(string), {})
  }))
  default = {}
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
