output "mysql_flexible_servers" {
  description = "A map of all created Azure MySQL Flexible Server module instances."
  value       = module.mysql_flexible_server
  sensitive   = true
}

output "mysql_flexible_server_ids" {
  description = "A map of server names to their resource IDs."
  value       = { for k, v in module.mysql_flexible_server : k => v.id }
}

output "mysql_flexible_server_fqdns" {
  description = "A map of server names to their FQDNs."
  value       = { for k, v in module.mysql_flexible_server : k => v.fqdn }
}
