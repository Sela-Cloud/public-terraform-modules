output "id" {
  description = "The ID of the Subnet."
  value       = azurerm_subnet.subnet.id
}

output "name" {
  description = "The Name of the Subnet."
  value       = azurerm_subnet.subnet.name
}

output "resource_group_name" {
  description = "The Resource Group in which the Subnet exists."
  value       = azurerm_subnet.subnet.resource_group_name
}

output "virtual_network_name" {
  description = "The Virtual Network associated with the Subnet."
  value       = azurerm_subnet.subnet.virtual_network_name
}

output "address_prefixes" {
  description = "The Address Prefixes of the Subnet."
  value       = azurerm_subnet.subnet.address_prefixes
}

output "subnet" {
  description = "The complete Azure Subnet resource object."
  value       = azurerm_subnet.subnet
}