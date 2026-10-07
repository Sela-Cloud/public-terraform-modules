output "rds_instances" {
  description = "Map of all created RDS instances and their attributes."
  value       = module.rds
}

output "db_instance_ids" {
  description = "Map of instance identifiers to their RDS instance IDs."
  value       = { for k, v in module.rds : k => v.id }
}

output "db_instance_endpoints" {
  description = "Map of instance identifiers to their connection endpoints."
  value       = { for k, v in module.rds : k => v.endpoint }
}

output "db_instance_addresses" {
  description = "Map of instance identifiers to their hostnames."
  value       = { for k, v in module.rds : k => v.db_instance_address }
}

output "db_security_group_ids" {
  description = "Map of instance identifiers to their security group IDs."
  value       = { for k, v in module.rds : k => v.security_group_id }
}
