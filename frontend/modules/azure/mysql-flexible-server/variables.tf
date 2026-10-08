variable "mysql_flexible_server" {
  description = "Map of Azure Database for MySQL Flexible Server configurations."
  type = map(object({
    name                   = string
    resource_group_name    = string
    location               = string
    administrator_login    = optional(string, "mysqladmin")
    administrator_password = optional(string, null)
    sku_name               = optional(string, "B_Standard_B1ms")
    server_version         = optional(string, "8.0.21")

    storage = optional(object({
      size_gb            = optional(number, 20)
      iops               = optional(number, 360)
      auto_grow_enabled  = optional(bool, true)
      io_scaling_enabled = optional(bool, false)
      }), {
      size_gb            = 20
      iops               = 360
      auto_grow_enabled  = true
      io_scaling_enabled = false
    })

    high_availability = optional(object({
      mode                      = string
      standby_availability_zone = optional(string, null)
    }), null)

    maintenance_window = optional(object({
      day_of_week  = optional(number, 0)
      start_hour   = optional(number, 0)
      start_minute = optional(number, 0)
    }), null)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)

    backup_retention_days             = optional(number, 7)
    geo_redundant_backup_enabled      = optional(bool, false)
    delegated_subnet_id               = optional(string, null)
    private_dns_zone_id               = optional(string, null)
    public_network_access             = optional(string, "Enabled")
    zone                              = optional(string, null)
    create_mode                       = optional(string, "Default")
    point_in_time_restore_time_in_utc = optional(string, null)
    source_server_id                  = optional(string, null)
    replication_role                  = optional(string, null)

    databases = optional(map(object({
      charset   = optional(string, "utf8mb4")
      collation = optional(string, "utf8mb4_unicode_ci")
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
