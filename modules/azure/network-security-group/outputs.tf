output "id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg.id
}

output "name" {
  description = "The Name of the Network Security Group."
  value       = azurerm_network_security_group.nsg.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Network Security Group was created."
  value       = azurerm_network_security_group.nsg.resource_group_name
}

output "location" {
  description = "The Azure Region of the Network Security Group."
  value       = azurerm_network_security_group.nsg.location
}

output "security_rules" {
  description = "The list of security rules configured in the Network Security Group."
  value       = azurerm_network_security_group.nsg.security_rule
}

output "network_security_group" {
  description = "The full Azure Network Security Group resource object."
  value       = azurerm_network_security_group.nsg
}
