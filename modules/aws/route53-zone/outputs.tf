output "id" {
  description = "The hosted zone ID."
  value       = aws_route53_zone.this.id
}

output "arn" {
  description = "The ARN of the hosted zone."
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "The zone's delegation set name servers, to configure at the domain registrar."
  value       = aws_route53_zone.this.name_servers
}

output "primary_name_server" {
  description = "The Route 53 name server that created the SOA record."
  value       = aws_route53_zone.this.primary_name_server
}
