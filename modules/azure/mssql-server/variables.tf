variable "name" {
  description = "(Required) The name of the Microsoft SQL Server. This needs to be globally unique within Azure."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Microsoft SQL Server."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "server_version" {
  description = "(Required) The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Defaults to 12.0."
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "(Optional) The administrator login name for the new server. Required unless azuread_authentication_only is true."
  type        = string
  default     = "sqladmin"
}

variable "administrator_login_password" {
  description = "(Optional) The password associated with the administrator_login user. Required unless azuread_authentication_only is true."
  type        = string
  default     = null
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "(Optional) The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases on the server. Valid values are: 1.0, 1.1, and 1.2. Defaults to 1.2."
  type        = string
  default     = "1.2"
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this server. Defaults to true."
  type        = bool
  default     = true
}

variable "outbound_network_restriction_enabled" {
  description = "(Optional) Whether outbound network traffic is restricted for this server. Defaults to false."
  type        = bool
  default     = false
}

variable "connection_policy" {
  description = "(Optional) The connection policy the server will use. Possible values are Default, Proxy, and Redirect. Defaults to Default."
  type        = string
  default     = "Default"
}

variable "azuread_administrator" {
  description = "(Optional) An Azure Active Directory Administrator block for this SQL Server."
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = optional(string, null)
    azuread_authentication_only = optional(bool, false)
  })
  default = null
}

variable "identity" {
  description = "(Optional) An identity block."
  type = object({
    type         = string
    identity_ids = optional(list(string), null)
  })
  default = null
}

variable "databases" {
  description = "(Optional) Map of databases to create on the SQL Server."
  type = map(object({
    sku_name                    = optional(string, "Basic")
    max_size_gb                 = optional(number, 2)
    collation                   = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    license_type                = optional(string, "LicenseIncluded")
    min_capacity                = optional(number, null)
    auto_pause_delay_in_minutes = optional(number, null)
    zone_redundant              = optional(bool, false)
    storage_account_type        = optional(string, "Local")
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "firewall_rules" {
  description = "(Optional) Map of firewall rules to create for the SQL Server."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "allow_azure_services_access" {
  description = "(Optional) Whether to allow Azure services and resources to access this server (creates firewall rule 0.0.0.0 to 0.0.0.0). Defaults to false."
  type        = bool
  default     = false
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
