output "id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.server.id
}

output "name" {
  description = "The Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.server.name
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.server.fqdn
}

output "administrator_login" {
  description = "The Administrator login for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.server.administrator_login
}

output "database_ids" {
  description = "Map of created database names to their resource IDs."
  value       = { for k, v in azurerm_postgresql_flexible_server_database.database : k => v.id }
}

output "firewall_rule_ids" {
  description = "Map of created firewall rule names to their resource IDs."
  value       = { for k, v in azurerm_postgresql_flexible_server_firewall_rule.firewall_rule : k => v.id }
}

output "server" {
  description = "The full PostgreSQL Flexible Server resource object."
  value       = azurerm_postgresql_flexible_server.server
  sensitive   = true
}
