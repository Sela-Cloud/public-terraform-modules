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

output "origin_access_control_ids" {
  description = "IDs of the Origin Access Controls created for each distribution, keyed by resource name, then origin name."
  value       = { for key, c in module.cloudfront : key => c.origin_access_control_ids }
}

output "s3_bucket_policies" {
  description = "Bucket policies letting each distribution read its S3 buckets through Origin Access Control, keyed by resource name, then bucket. Apply them where each bucket's policy is managed, unless the distribution grants access itself."
  value       = { for key, c in module.cloudfront : key => c.s3_bucket_policies }
}
