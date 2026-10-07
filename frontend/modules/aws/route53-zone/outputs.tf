output "zone_ids" {
  description = "Hosted zone ID of each zone, keyed by resource name."
  value       = { for key, z in module.route53_zone : key => z.id }
}

output "name_servers" {
  description = "Delegation set name servers of each zone, keyed by resource name."
  value       = { for key, z in module.route53_zone : key => z.name_servers }
}
