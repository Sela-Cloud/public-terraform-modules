output "id" {
  description = "The distribution's identifier."
  value       = aws_cloudfront_distribution.this.id
}

output "arn" {
  description = "The ARN of the distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "The distribution's CloudFront domain name (d111111abcdef8.cloudfront.net)."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID, used when aliasing a Route 53 record to this distribution."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "status" {
  description = "Current status of the distribution."
  value       = aws_cloudfront_distribution.this.status
}

output "etag" {
  description = "Current version of the distribution's configuration."
  value       = aws_cloudfront_distribution.this.etag
}
