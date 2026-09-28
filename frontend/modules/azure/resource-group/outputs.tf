output "resource_groups" {
  description = "Map of created Resource Groups and their attributes."
  value       = module.resource_group
}

output "resource_group_ids" {
  description = "Map of Resource Group names to their Azure resource IDs."
  value       = { for k, v in module.resource_group : k => v.id }
}
