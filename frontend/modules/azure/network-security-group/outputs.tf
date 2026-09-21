output "network_security_groups" {
  description = "Map of created Network Security Groups and their attributes."
  value       = module.network_security_group
}

output "network_security_group_ids" {
  description = "Map of Network Security Group names to their Azure resource IDs."
  value       = { for k, v in module.network_security_group : k => v.id }
}
