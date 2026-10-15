output "storage_containers" {
  description = "Map of created Storage Containers and their attributes."
  value       = module.storage_container
}

output "storage_container_ids" {
  description = "Map of Storage Container names to their resource IDs."
  value       = { for k, v in module.storage_container : k => v.id }
}
