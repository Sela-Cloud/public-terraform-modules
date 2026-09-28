output "id" {
  description = "The ID of the Resource Group."
  value       = azurerm_resource_group.rg.id
}

output "name" {
  description = "The Name of the Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "The Azure Region of the Resource Group."
  value       = azurerm_resource_group.rg.location
}

output "resource_group" {
  description = "The full Azure Resource Group resource object."
  value       = azurerm_resource_group.rg
}
