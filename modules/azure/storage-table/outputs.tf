output "id" {
  description = "The ID of the Storage Table."
  value       = azurerm_storage_table.table.id
}

output "name" {
  description = "The name of the Storage Table."
  value       = azurerm_storage_table.table.name
}

output "resource_manager_id" {
  description = "The Resource Manager ID of the Storage Table."
  value       = azurerm_storage_table.table.resource_manager_id
}

output "storage_table" {
  description = "The full Azure Storage Table resource object."
  value       = azurerm_storage_table.table
}
