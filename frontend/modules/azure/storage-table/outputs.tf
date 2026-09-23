output "storage_tables" {
  description = "Map of created Storage Tables and their attributes."
  value       = module.storage_table
}

output "storage_table_ids" {
  description = "Map of Storage Table keys to their Azure resource IDs."
  value       = { for k, v in module.storage_table : k => v.id }
}

output "storage_table_resource_manager_ids" {
  description = "Map of Storage Table keys to their Resource Manager IDs."
  value       = { for k, v in module.storage_table : k => v.resource_manager_id }
}
