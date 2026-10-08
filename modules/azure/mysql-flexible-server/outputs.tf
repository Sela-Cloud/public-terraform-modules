output "id" {
  description = "The ID of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.server.id
}

output "name" {
  description = "The Name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.server.name
}

output "fqdn" {
  description = "The fully qualified domain name of the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.server.fqdn
}

output "administrator_login" {
  description = "The Administrator login for the MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.server.administrator_login
}

output "database_ids" {
  description = "Map of created database names to their resource IDs."
  value       = { for k, v in azurerm_mysql_flexible_database.database : k => v.id }
}

output "firewall_rule_ids" {
  description = "Map of created firewall rule names to their resource IDs."
  value       = { for k, v in azurerm_mysql_flexible_server_firewall_rule.firewall_rule : k => v.id }
}

output "server" {
  description = "The full MySQL Flexible Server resource object."
  value       = azurerm_mysql_flexible_server.server
  sensitive   = true
}
