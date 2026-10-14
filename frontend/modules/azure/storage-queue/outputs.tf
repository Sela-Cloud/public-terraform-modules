output "storage_queues" {
  description = "Map of created Storage Queues and their attributes."
  value       = module.storage_queue
}

output "storage_queue_ids" {
  description = "Map of Storage Queue keys to their Azure resource IDs."
  value       = { for k, v in module.storage_queue : k => v.id }
}

output "storage_queue_names" {
  description = "Map of Storage Queue keys to their names."
  value       = { for k, v in module.storage_queue : k => v.name }
}

output "storage_queue_urls" {
  description = "Map of Storage Queue keys to their URLs."
  value       = { for k, v in module.storage_queue : k => v.url }
}
