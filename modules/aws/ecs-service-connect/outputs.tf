output "arn" {
  description = "ARN of the namespace. Pass it to a cluster's default namespace or a service's Service Connect namespace."
  value       = aws_service_discovery_http_namespace.this.arn
}

output "id" {
  description = "ID of the namespace."
  value       = aws_service_discovery_http_namespace.this.id
}

output "name" {
  description = "Name of the namespace."
  value       = aws_service_discovery_http_namespace.this.name
}
