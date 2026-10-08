variable "postgresql_flexible_server" {
  description = "Map of Azure Database for PostgreSQL Flexible Server configurations."
  type = map(object({
    name                              = string
    resource_group_name               = string
    location                          = string
    administrator_login               = optional(string, "pgadmin")
    administrator_password            = optional(string, null)
    sku_name                          = optional(string, "B_Standard_B1ms")
    server_version                    = optional(string, "16")
    storage_mb                        = optional(number, 32768)
    storage_tier                      = optional(string, null)
    auto_grow_enabled                 = optional(bool, true)
    backup_retention_days             = optional(number, 7)
    geo_redundant_backup_enabled      = optional(bool, false)
    delegated_subnet_id               = optional(string, null)
    private_dns_zone_id               = optional(string, null)
    public_network_access_enabled     = optional(bool, true)
    zone                              = optional(string, null)
    create_mode                       = optional(string, "Default")
    point_in_time_restore_time_in_utc = optional(string, null)
    source_server_id                  = optional(string, null)
    replication_role                  = optional(string, null)

    high_availability = optional(object({
      mode                      = string
      standby_availability_zone = optional(string, null)
    }), null)

    maintenance_window = optional(object({
      day_of_week  = optional(number, 0)
      start_hour   = optional(number, 0)
      start_minute = optional(number, 0)
    }), null)

    authentication = optional(object({
      active_directory_auth_enabled = optional(bool, false)
      password_auth_enabled         = optional(bool, true)
      tenant_id                     = optional(string, null)
    }), null)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)

    databases = optional(map(object({
      charset   = optional(string, "UTF8")
      collation = optional(string, "en_US.utf8")
    })), {})

    firewall_rules = optional(map(object({
      start_ip_address = string
      end_ip_address   = string
    })), {})

    server_parameters = optional(map(string), {})
    tags              = optional(map(string), {})
  }))
  default = {}
}
