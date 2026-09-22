output "id" {
  description = "The ID of the VPN Gateway."
  value       = azurerm_vpn_gateway.gateway.id
}

output "name" {
  description = "The Name of the VPN Gateway."
  value       = azurerm_vpn_gateway.gateway.name
}

output "bgp_settings" {
  description = "The BGP settings of the VPN Gateway, including computed BGP peering addresses."
  value       = azurerm_vpn_gateway.gateway.bgp_settings
}

output "vpn_gateway" {
  description = "The full Azure VPN Gateway resource object."
  value       = azurerm_vpn_gateway.gateway
}
