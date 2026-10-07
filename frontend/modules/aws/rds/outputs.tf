output "rds_instances" {
  description = "Map of all created RDS instances and their non-sensitive attributes. Excludes db_instance_username, which the child module marks sensitive -- see db_instance_username's own output below if a consumer specifically needs it."
  value = {
    for k, v in module.rds : k => {
      id                = v.id
      arn               = v.arn
      endpoint          = v.endpoint
      address           = v.db_instance_address
      port              = v.db_instance_port
      status            = v.db_instance_status
      availability_zone = v.db_instance_availability_zone
      hosted_zone_id    = v.db_instance_hosted_zone_id
      resource_id       = v.db_instance_resource_id
      subnet_group_id   = v.db_subnet_group_id
      security_group_id = v.security_group_id
    }
  }
}

output "db_instance_username" {
  description = "Map of instance identifiers to their master usernames."
  value       = { for k, v in module.rds : k => v.db_instance_username }
  sensitive   = true
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
