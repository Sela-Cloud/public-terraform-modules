output "id" {
  description = "The ID of the Microsoft SQL Server."
  value       = azurerm_mssql_server.server.id
}

output "name" {
  description = "The Name of the Microsoft SQL Server."
  value       = azurerm_mssql_server.server.name
}

output "fully_qualified_domain_name" {
  description = "The fully qualified domain name of the Azure SQL Server (e.g. servername.database.windows.net)."
  value       = azurerm_mssql_server.server.fully_qualified_domain_name
}

output "administrator_login" {
  description = "The administrator login name for the server."
  value       = azurerm_mssql_server.server.administrator_login
}

output "database_ids" {
  description = "Map of created database names to their resource IDs."
  value       = { for k, v in azurerm_mssql_database.database : k => v.id }
}

output "firewall_rule_ids" {
  description = "Map of created firewall rule names to their resource IDs."
  value       = { for k, v in azurerm_mssql_firewall_rule.firewall_rule : k => v.id }
}

output "server" {
  description = "The full Microsoft SQL Server resource object."
  value       = azurerm_mssql_server.server
  sensitive   = true
}
