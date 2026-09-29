output "id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "name" {
  description = "The Name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Virtual Network was created."
  value       = azurerm_virtual_network.vnet.resource_group_name
}

output "location" {
  description = "The Azure Region of the Virtual Network."
  value       = azurerm_virtual_network.vnet.location
}

output "address_space" {
  description = "The list of address spaces partitioned for the Virtual Network."
  value       = azurerm_virtual_network.vnet.address_space
}

output "dns_servers" {
  description = "The list of DNS servers configured for the Virtual Network."
  value       = azurerm_virtual_network.vnet.dns_servers
}

output "guid" {
  description = "The GUID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.guid
}

output "virtual_network" {
  description = "The full Azure Virtual Network resource object."
  value       = azurerm_virtual_network.vnet
}
