output "id" {
  description = "The ID of the SQL Managed Instance."
  value       = azurerm_mssql_managed_instance.managed_instance.id
}

output "name" {
  description = "The Name of the SQL Managed Instance."
  value       = azurerm_mssql_managed_instance.managed_instance.name
}

output "fqdn" {
  description = "The fully qualified domain name of the Azure Managed Instance."
  value       = azurerm_mssql_managed_instance.managed_instance.fqdn
}

output "administrator_login" {
  description = "The administrator login name for the SQL Managed Instance."
  value       = azurerm_mssql_managed_instance.managed_instance.administrator_login
}

output "managed_database_ids" {
  description = "Map of created managed database names to their resource IDs."
  value       = { for k, v in azurerm_mssql_managed_database.managed_database : k => v.id }
}

output "managed_instance" {
  description = "The full Azure SQL Managed Instance resource object."
  value       = azurerm_mssql_managed_instance.managed_instance
  sensitive   = true
}
