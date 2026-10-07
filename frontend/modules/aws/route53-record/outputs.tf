output "record_ids" {
  description = "ID of each record, keyed by resource name."
  value       = { for key, r in module.route53_record : key => r.id }
}

output "fqdns" {
  description = "Fully qualified domain name of each record, keyed by resource name."
  value       = { for key, r in module.route53_record : key => r.fqdn }
}
