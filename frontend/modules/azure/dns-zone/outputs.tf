output "dns_zones" {
  description = "Map of created DNS Zones and their attributes."
  value       = module.dns_zone
}

output "dns_zone_ids" {
  description = "Map of DNS Zone names to their Azure resource IDs."
  value       = { for k, v in module.dns_zone : k => v.id }
}

output "dns_zone_name_servers" {
  description = "Map of DNS Zone names to their assigned name servers."
  value       = { for k, v in module.dns_zone : k => v.name_servers }
}
