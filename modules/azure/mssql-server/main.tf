resource "azurerm_mssql_server" "server" {
  name                                 = var.name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  version                              = var.server_version
  administrator_login                  = var.administrator_login
  administrator_login_password         = var.administrator_login_password
  minimum_tls_version                  = var.minimum_tls_version
  public_network_access_enabled        = var.public_network_access_enabled
  outbound_network_restriction_enabled = var.outbound_network_restriction_enabled
  connection_policy                    = var.connection_policy
  tags                                 = var.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
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

resource "azurerm_mssql_database" "database" {
  for_each = var.databases

  name                        = each.key
  server_id                   = azurerm_mssql_server.server.id
  collation                   = coalesce(each.value.collation, "SQL_Latin1_General_CP1_CI_AS")
  license_type                = each.value.license_type
  max_size_gb                 = each.value.max_size_gb
  sku_name                    = coalesce(each.value.sku_name, "Basic")
  min_capacity                = each.value.min_capacity
  auto_pause_delay_in_minutes = each.value.auto_pause_delay_in_minutes
  zone_redundant              = each.value.zone_redundant
  storage_account_type        = each.value.storage_account_type
  tags                        = merge(var.tags, each.value.tags)
}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count = var.allow_azure_services_access ? 1 : 0

  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
