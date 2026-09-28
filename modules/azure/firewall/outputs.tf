output "id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.firewall.id
}

output "name" {
  description = "The Name of the Azure Firewall."
  value       = azurerm_firewall.firewall.name
}

output "ip_configuration" {
  description = "The IP configuration block of the Azure Firewall, including the computed private_ip_address."
  value       = azurerm_firewall.firewall.ip_configuration
}

output "virtual_hub" {
  description = "The virtual hub block of the Azure Firewall if configured."
  value       = azurerm_firewall.firewall.virtual_hub
}

output "firewall" {
  description = "The full Azure Firewall resource object."
  value       = azurerm_firewall.firewall
}
