output "postgresql_flexible_servers" {
  description = "A map of all created Azure PostgreSQL Flexible Server module instances."
  value       = module.postgresql_flexible_server
  sensitive   = true
}

output "postgresql_flexible_server_ids" {
  description = "A map of server names to their resource IDs."
  value       = { for k, v in module.postgresql_flexible_server : k => v.id }
}

output "postgresql_flexible_server_fqdns" {
  description = "A map of server names to their FQDNs."
  value       = { for k, v in module.postgresql_flexible_server : k => v.fqdn }
}
