output "mssql_managed_instances" {
  description = "A map of all created Azure SQL Managed Instance module instances."
  value       = module.mssql_managed_instance
  sensitive   = true
}

output "mssql_managed_instance_ids" {
  description = "A map of Managed Instance names to their resource IDs."
  value       = { for k, v in module.mssql_managed_instance : k => v.id }
}

output "mssql_managed_instance_fqdns" {
  description = "A map of Managed Instance names to their fully qualified domain names."
  value       = { for k, v in module.mssql_managed_instance : k => v.fqdn }
}
