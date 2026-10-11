output "id" {
  description = "The ID of the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.id
}

output "name" {
  description = "The Name of the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Private Endpoint was created."
  value       = azurerm_private_endpoint.endpoint.resource_group_name
}

output "location" {
  description = "The Azure Region where the Private Endpoint exists."
  value       = azurerm_private_endpoint.endpoint.location
}

output "subnet_id" {
  description = "The ID of the Subnet from which the private IP was allocated."
  value       = azurerm_private_endpoint.endpoint.subnet_id
}

output "network_interface" {
  description = "The network interface objects created by the Private Endpoint, containing id and name."
  value       = azurerm_private_endpoint.endpoint.network_interface
}

output "custom_network_interface_name" {
  description = "The custom network interface name attached to the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.custom_network_interface_name
}

output "private_dns_zone_configs" {
  description = "The list of private DNS zone configurations associated with the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.private_dns_zone_configs
}

output "private_dns_zone_group" {
  description = "The Private DNS Zone Group block associated with the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.private_dns_zone_group
}

output "private_service_connection" {
  description = "The Private Service Connection block containing connection status and private IP address allocations."
  value       = azurerm_private_endpoint.endpoint.private_service_connection
}

output "ip_configuration" {
  description = "The static IP configuration blocks of the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.ip_configuration
}

output "tags" {
  description = "The tags assigned to the Private Endpoint."
  value       = azurerm_private_endpoint.endpoint.tags
}

output "private_endpoint" {
  description = "The full Azure Private Endpoint resource object."
  value       = azurerm_private_endpoint.endpoint
}
