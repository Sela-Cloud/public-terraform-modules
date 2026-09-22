output "id" {
  description = "The ID of the Virtual Network Peering."
  value       = azurerm_virtual_network_peering.peering.id
}

output "name" {
  description = "The Name of the Virtual Network Peering."
  value       = azurerm_virtual_network_peering.peering.name
}

output "resource_group_name" {
  description = "The Resource Group Name in which the Virtual Network Peering was created."
  value       = azurerm_virtual_network_peering.peering.resource_group_name
}

output "virtual_network_name" {
  description = "The Name of the local Virtual Network."
  value       = azurerm_virtual_network_peering.peering.virtual_network_name
}

output "remote_virtual_network_id" {
  description = "The Resource ID of the remote Virtual Network."
  value       = azurerm_virtual_network_peering.peering.remote_virtual_network_id
}

output "virtual_network_peering" {
  description = "The full Azure Virtual Network Peering resource object."
  value       = azurerm_virtual_network_peering.peering
}
