output "mssql_servers" {
  description = "A map of all created Azure SQL Server module instances."
  value       = module.mssql_server
  sensitive   = true
}

output "mssql_server_ids" {
  description = "A map of server names to their resource IDs."
  value       = { for k, v in module.mssql_server : k => v.id }
}

output "mssql_server_fqdns" {
  description = "A map of server names to their fully qualified domain names."
  value       = { for k, v in module.mssql_server : k => v.fully_qualified_domain_name }
}
