output "application_security_groups" {
  description = "Map of created Application Security Groups and their attributes."
  value       = module.application_security_group
}

output "application_security_group_ids" {
  description = "Map of Application Security Group names to their Azure resource IDs."
  value       = { for k, v in module.application_security_group : k => v.id }
}
