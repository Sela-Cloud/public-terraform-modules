output "id" {
  description = "The ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.identity.id
}

output "name" {
  description = "The name of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.identity.name
}

output "principal_id" {
  description = "The ID of the Service Principal object associated with the created Identity."
  value       = azurerm_user_assigned_identity.identity.principal_id
}

output "client_id" {
  description = "The Client ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.identity.client_id
}

output "tenant_id" {
  description = "The Tenant ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.identity.tenant_id
}

output "resource_group_name" {
  description = "The name of the Resource Group in which the User Assigned Identity was created."
  value       = azurerm_user_assigned_identity.identity.resource_group_name
}

output "location" {
  description = "The Azure Region where the User Assigned Identity was created."
  value       = azurerm_user_assigned_identity.identity.location
}

output "tags" {
  description = "A mapping of tags assigned to the User Assigned Identity."
  value       = azurerm_user_assigned_identity.identity.tags
}

output "user_assigned_identity" {
  description = "The full Azure User Assigned Identity resource object."
  value       = azurerm_user_assigned_identity.identity
}

output "role_assignments" {
  description = "Map of created role assignments associated with this Managed Identity."
  value       = azurerm_role_assignment.role_assignment
}
