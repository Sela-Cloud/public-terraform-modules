variable "mssql_managed_instance" {
  description = "Map of Azure SQL Managed Instance configurations."
  type = map(object({
    name                           = string
    resource_group_name            = string
    location                       = string
    sku_name                       = string
    vcores                         = number
    storage_size_in_gb             = number
    subnet_id                      = string
    license_type                   = string
    administrator_login            = optional(string, "sqladmin")
    administrator_login_password   = optional(string, null)
    collation                      = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    timezone_id                    = optional(string, "UTC")
    minimum_tls_version            = optional(string, "1.2")
    proxy_override                 = optional(string, "Default")
    public_data_endpoint_enabled   = optional(bool, false)
    storage_account_type           = optional(string, "GRS")
    storage_iops                   = optional(number, null)
    zone_redundant_enabled         = optional(bool, false)
    dns_zone_partner_id            = optional(string, null)
    maintenance_configuration_name = optional(string, null)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)

    azure_active_directory_administrator = optional(object({
      login_username                      = string
      object_id                           = string
      principal_type                      = optional(string, "User")
      tenant_id                           = optional(string, null)
      azuread_authentication_only_enabled = optional(bool, false)
    }), null)

    managed_databases = optional(map(object({
      short_term_retention_days = optional(number, 7)
      tags                      = optional(map(string), {})
    })), {})

    tags = optional(map(string), {})
  }))
  default = {}
}
