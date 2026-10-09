output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "name" {
  description = "The Name of the Key Vault."
  value       = azurerm_key_vault.key_vault.name
}

output "vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.key_vault.vault_uri
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Key Vault was created."
  value       = azurerm_key_vault.key_vault.resource_group_name
}

output "location" {
  description = "The Azure Region of the Key Vault."
  value       = azurerm_key_vault.key_vault.location
}

output "sku_name" {
  description = "The SKU Name of the Key Vault."
  value       = azurerm_key_vault.key_vault.sku_name
}

output "key_vault" {
  description = "The full Azure Key Vault resource object."
  value       = azurerm_key_vault.key_vault
}
