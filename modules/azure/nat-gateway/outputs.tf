output "id" {
  description = "The ID of the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.id
}

output "name" {
  description = "The Name of the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the NAT Gateway was created."
  value       = azurerm_nat_gateway.nat_gateway.resource_group_name
}

output "location" {
  description = "The Azure Region of the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.location
}

output "resource_guid" {
  description = "The resource GUID property of the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.resource_guid
}

output "sku_name" {
  description = "The SKU of the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.sku_name
}

output "idle_timeout_in_minutes" {
  description = "The idle timeout in minutes for the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.idle_timeout_in_minutes
}

output "zones" {
  description = "The Availability Zones associated with the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.zones
}

output "tags" {
  description = "The tags assigned to the NAT Gateway."
  value       = azurerm_nat_gateway.nat_gateway.tags
}

output "nat_gateway" {
  description = "The full Azure NAT Gateway resource object."
  value       = azurerm_nat_gateway.nat_gateway
}
