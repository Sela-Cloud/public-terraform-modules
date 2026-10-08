resource "azurerm_mssql_managed_instance" "managed_instance" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  sku_name                       = var.sku_name
  vcores                         = var.vcores
  storage_size_in_gb             = var.storage_size_in_gb
  subnet_id                      = var.subnet_id
  license_type                   = var.license_type
  administrator_login            = var.administrator_login
  administrator_login_password   = var.administrator_login_password
  collation                      = var.collation
  timezone_id                    = var.timezone_id
  minimum_tls_version            = var.minimum_tls_version
  proxy_override                 = var.proxy_override
  public_data_endpoint_enabled   = var.public_data_endpoint_enabled
  storage_account_type           = var.storage_account_type
  storage_iops                   = var.storage_iops
  zone_redundant_enabled         = var.zone_redundant_enabled
  dns_zone_partner_id            = var.dns_zone_partner_id
  maintenance_configuration_name = var.maintenance_configuration_name
  tags                           = var.tags

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "azure_active_directory_administrator" {
    for_each = var.azure_active_directory_administrator != null ? [var.azure_active_directory_administrator] : []
    content {
      login_username                      = azure_active_directory_administrator.value.login_username
      object_id                           = azure_active_directory_administrator.value.object_id
      principal_type                      = coalesce(azure_active_directory_administrator.value.principal_type, "User")
      tenant_id                           = azure_active_directory_administrator.value.tenant_id
      azuread_authentication_only_enabled = azure_active_directory_administrator.value.azuread_authentication_only_enabled
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

resource "azurerm_mssql_managed_database" "managed_database" {
  for_each = var.managed_databases

  name                      = each.key
  managed_instance_id       = azurerm_mssql_managed_instance.managed_instance.id
  short_term_retention_days = each.value.short_term_retention_days
  tags                      = merge(var.tags, each.value.tags)
}
