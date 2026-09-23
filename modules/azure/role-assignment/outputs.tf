output "id" {
  description = "The ID of the Role Assignment."
  value       = azurerm_role_assignment.role_assignment.id
}

output "name" {
  description = "The name of the Role Assignment (GUID)."
  value       = azurerm_role_assignment.role_assignment.name
}

output "scope" {
  description = "The scope at which the Role Assignment was applied."
  value       = azurerm_role_assignment.role_assignment.scope
}

output "principal_id" {
  description = "The ID of the Principal assigned to the role."
  value       = azurerm_role_assignment.role_assignment.principal_id
}

output "principal_type" {
  description = "The type of the Principal assigned to the role."
  value       = azurerm_role_assignment.role_assignment.principal_type
}

output "role_definition_id" {
  description = "The Scoped-ID of the Role Definition applied."
  value       = azurerm_role_assignment.role_assignment.role_definition_id
}

output "role_definition_name" {
  description = "The name of the built-in Role applied."
  value       = azurerm_role_assignment.role_assignment.role_definition_name
}

output "role_assignment" {
  description = "The full Azure Role Assignment resource object."
  value       = azurerm_role_assignment.role_assignment
}
