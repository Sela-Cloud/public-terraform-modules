resource "azurerm_mysql_flexible_server" "server" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  administrator_login               = var.create_mode == "Default" ? var.administrator_login : null
  administrator_password            = var.create_mode == "Default" ? var.administrator_password : null
  sku_name                          = var.sku_name
  version                           = var.server_version
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns_zone_id
  public_network_access             = var.delegated_subnet_id != null ? "Disabled" : var.public_network_access
  zone                              = var.zone
  create_mode                       = var.create_mode
  point_in_time_restore_time_in_utc = var.point_in_time_restore_time_in_utc
  source_server_id                  = var.source_server_id
  replication_role                  = var.replication_role
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  tags                              = var.tags

  dynamic "storage" {
    for_each = var.storage != null ? [var.storage] : []
    content {
      size_gb            = storage.value.size_gb
      iops               = storage.value.iops
      auto_grow_enabled  = storage.value.auto_grow_enabled
      io_scaling_enabled = storage.value.io_scaling_enabled
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [var.high_availability] : []
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "timeouts" {
    for_each = length(keys(var.timeouts)) > 0 ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_mysql_flexible_database" "database" {
  for_each = var.databases

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.server.name
  charset             = coalesce(each.value.charset, "utf8mb4")
  collation           = coalesce(each.value.collation, "utf8mb4_unicode_ci")
}

resource "azurerm_mysql_flexible_server_firewall_rule" "firewall_rule" {
  for_each = var.firewall_rules

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.server.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

resource "azurerm_mysql_flexible_server_configuration" "configuration" {
  for_each = var.server_parameters

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.server.name
  value               = each.value
}
