output "id" {
  description = "The ID of the Public IP."
  value       = azurerm_public_ip.public_ip.id
}

output "name" {
  description = "The Name of the Public IP."
  value       = azurerm_public_ip.public_ip.name
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the Public IP was created."
  value       = azurerm_public_ip.public_ip.resource_group_name
}

output "location" {
  description = "The Azure Region of the Public IP."
  value       = azurerm_public_ip.public_ip.location
}

output "ip_address" {
  description = "The IP address value that was allocated."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "fqdn" {
  description = "The Fully Qualified Domain Name of the DNS record associated with the Public IP."
  value       = azurerm_public_ip.public_ip.fqdn
}

output "sku" {
  description = "The SKU of the Public IP."
  value       = azurerm_public_ip.public_ip.sku
}

output "sku_tier" {
  description = "The SKU Tier of the Public IP."
  value       = azurerm_public_ip.public_ip.sku_tier
}

output "allocation_method" {
  description = "The allocation method of the Public IP."
  value       = azurerm_public_ip.public_ip.allocation_method
}

output "zones" {
  description = "The Availability Zones associated with the Public IP."
  value       = azurerm_public_ip.public_ip.zones
}

output "tags" {
  description = "The tags assigned to the Public IP."
  value       = azurerm_public_ip.public_ip.tags
}

output "public_ip" {
  description = "The full Azure Public IP resource object."
  value       = azurerm_public_ip.public_ip
}
