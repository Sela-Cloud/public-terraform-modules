output "id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.storage_account.id
}

output "name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.storage_account.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Storage Account was created."
  value       = azurerm_storage_account.storage_account.resource_group_name
}

output "location" {
  description = "The Azure Region of the Storage Account."
  value       = azurerm_storage_account.storage_account.location
}

output "primary_location" {
  description = "The primary location of the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_location
}

output "secondary_location" {
  description = "The secondary location of the Storage Account."
  value       = azurerm_storage_account.storage_account.secondary_location
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname for blob storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location."
  value       = azurerm_storage_account.storage_account.secondary_blob_endpoint
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_dfs_endpoint
}

output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_web_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storage_account.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account."
  value       = azurerm_storage_account.storage_account.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary blob location."
  value       = azurerm_storage_account.storage_account.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The connection string associated with the secondary blob location."
  value       = azurerm_storage_account.storage_account.secondary_connection_string
  sensitive   = true
}

output "identity" {
  description = "The Azure Active Directory Managed Service Identity object."
  value       = azurerm_storage_account.storage_account.identity
}

output "storage_account" {
  description = "The full Azure Storage Account resource object."
  value       = azurerm_storage_account.storage_account
  sensitive   = true
}
