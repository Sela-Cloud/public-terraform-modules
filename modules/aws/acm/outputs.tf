output "id" {
  description = "The ARN of the certificate."
  value       = aws_acm_certificate.this.id
}

output "arn" {
  description = "The ARN of the certificate."
  value       = aws_acm_certificate.this.arn
}

output "domain_name" {
  description = "The domain name of the certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "status" {
  description = "Status of the certificate."
  value       = aws_acm_certificate.this.status
}

output "domain_validation_options" {
  description = "Set of domain validation objects for DNS validation."
  value       = aws_acm_certificate.this.domain_validation_options
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_acm_certificate.this.tags_all
}
