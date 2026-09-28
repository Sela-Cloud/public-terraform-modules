output "id" {
  description = "The ID of the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.id
}

output "name" {
  description = "The Name of the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.name
}

output "resource_group_name" {
  description = "The Name of the Resource Group in which the DNS A Record exists."
  value       = azurerm_dns_a_record.dns_a_record.resource_group_name
}

output "zone_name" {
  description = "The Name of the DNS Zone in which the DNS A Record exists."
  value       = azurerm_dns_a_record.dns_a_record.zone_name
}

output "fqdn" {
  description = "The FQDN of the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.fqdn
}

output "ttl" {
  description = "The Time To Live of the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.ttl
}

output "records" {
  description = "The list of IPv4 addresses assigned to the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.records
}

output "target_resource_id" {
  description = "The target resource ID if the record is configured as an alias."
  value       = azurerm_dns_a_record.dns_a_record.target_resource_id
}

output "tags" {
  description = "The tags assigned to the DNS A Record."
  value       = azurerm_dns_a_record.dns_a_record.tags
}

output "dns_a_record" {
  description = "The full Azure DNS A Record resource object."
  value       = azurerm_dns_a_record.dns_a_record
}
