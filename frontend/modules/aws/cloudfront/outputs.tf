output "distribution_ids" {
  description = "ID of each distribution, keyed by resource name."
  value       = { for key, c in module.cloudfront : key => c.id }
}

output "domain_names" {
  description = "CloudFront domain name of each distribution, keyed by resource name."
  value       = { for key, c in module.cloudfront : key => c.domain_name }
}

output "hosted_zone_ids" {
  description = "CloudFront Route 53 zone ID of each distribution, keyed by resource name — use this to alias a Route 53 record to it."
  value       = { for key, c in module.cloudfront : key => c.hosted_zone_id }
}
