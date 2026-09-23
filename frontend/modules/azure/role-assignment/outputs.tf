output "role_assignments" {
  description = "Map of created Role Assignments and their attributes."
  value       = module.role_assignment
}

output "role_assignment_ids" {
  description = "Map of Role Assignment keys to their Azure resource IDs."
  value       = { for k, v in module.role_assignment : k => v.id }
}

output "role_assignment_principal_types" {
  description = "Map of Role Assignment keys to their principal types."
  value       = { for k, v in module.role_assignment : k => v.principal_type }
}
