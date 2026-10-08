variable "mssql_server" {
  description = "Map of Azure SQL Logical Server configurations."
  type = map(object({
    name                                 = string
    resource_group_name                  = string
    location                             = string
    server_version                       = optional(string, "12.0")
    administrator_login                  = optional(string, "sqladmin")
    administrator_login_password         = optional(string, null)
    minimum_tls_version                  = optional(string, "1.2")
    public_network_access_enabled        = optional(bool, true)
    outbound_network_restriction_enabled = optional(bool, false)
    connection_policy                    = optional(string, "Default")

    azuread_administrator = optional(object({
      login_username              = string
      object_id                   = string
      tenant_id                   = optional(string, null)
      azuread_authentication_only = optional(bool, false)
    }), null)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)

    databases = optional(map(object({
      sku_name                    = optional(string, "Basic")
      max_size_gb                 = optional(number, 2)
      collation                   = optional(string, "SQL_Latin1_General_CP1_CI_AS")
      license_type                = optional(string, "LicenseIncluded")
      min_capacity                = optional(number, null)
      auto_pause_delay_in_minutes = optional(number, null)
      zone_redundant              = optional(bool, false)
      storage_account_type        = optional(string, "Local")
      tags                        = optional(map(string), {})
    })), {})

    firewall_rules = optional(map(object({
      start_ip_address = string
      end_ip_address   = string
    })), {})

    allow_azure_services_access = optional(bool, false)
    tags                        = optional(map(string), {})
  }))
  default = {}
}
