output "id" {
  description = "The ID of the Local Network Gateway."
  value       = azurerm_local_network_gateway.gateway.id
}

output "name" {
  description = "The Name of the Local Network Gateway."
  value       = azurerm_local_network_gateway.gateway.name
}

output "bgp_settings" {
  description = "The BGP settings of the Local Network Gateway, if configured."
  value       = azurerm_local_network_gateway.gateway.bgp_settings
}

output "local_network_gateway" {
  description = "The full Azure Local Network Gateway resource object."
  value       = azurerm_local_network_gateway.gateway
}
