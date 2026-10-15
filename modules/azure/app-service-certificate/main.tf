resource "azurerm_app_service_certificate" "certificate" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_secret_id = var.key_vault_secret_id
  key_vault_id        = var.key_vault_id
  pfx_blob            = var.pfx_blob
  password            = var.password
  app_service_plan_id = var.app_service_plan_id
  tags                = var.tags
}
