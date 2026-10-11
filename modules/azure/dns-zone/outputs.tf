output "id" {
  description = "The ID of the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.id
}

output "name" {
  description = "The Name of the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.name
}

output "resource_group_name" {
  description = "The Name of the Resource Group in which the DNS Zone exists."
  value       = azurerm_dns_zone.dns_zone.resource_group_name
}

output "name_servers" {
  description = "A list of values that make up the NS record for the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.name_servers
}

output "number_of_record_sets" {
  description = "The number of records already in the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.number_of_record_sets
}

output "max_number_of_record_sets" {
  description = "The maximum number of records that can be created in the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.max_number_of_record_sets
}

output "tags" {
  description = "The tags assigned to the DNS Zone."
  value       = azurerm_dns_zone.dns_zone.tags
}

output "dns_zone" {
  description = "The full Azure DNS Zone resource object."
  value       = azurerm_dns_zone.dns_zone
}
