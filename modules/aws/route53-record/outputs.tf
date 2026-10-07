output "id" {
  description = "The record's ID."
  value       = aws_route53_record.this.id
}

output "fqdn" {
  description = "The fully qualified domain name of the record."
  value       = aws_route53_record.this.fqdn
}
