output "id" {
  description = "The ID of the Storage Queue."
  value       = azurerm_storage_queue.queue.id
}

output "name" {
  description = "The name of the Storage Queue."
  value       = azurerm_storage_queue.queue.name
}

output "url" {
  description = "The URL of the Storage Queue."
  value       = azurerm_storage_queue.queue.url
}

output "storage_queue" {
  description = "The full Azure Storage Queue resource object."
  value       = azurerm_storage_queue.queue
}
