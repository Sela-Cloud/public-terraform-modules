output "dns_a_records" {
  description = "Map of created DNS A Records and their attributes."
  value       = module.dns_a_record
}

output "dns_a_record_ids" {
  description = "Map of DNS A Record names to their Azure resource IDs."
  value       = { for k, v in module.dns_a_record : k => v.id }
}

output "dns_a_record_fqdns" {
  description = "Map of DNS A Record names to their FQDNs."
  value       = { for k, v in module.dns_a_record : k => v.fqdn }
}
