output "id" {
  description = "The ID of the Policy Definition."
  value       = azurerm_policy_definition.policy.id
}

output "name" {
  description = "The Name of the Policy Definition."
  value       = azurerm_policy_definition.policy.name
}

output "role_definition_ids" {
  description = "The list of Role Definition IDs extracted from the policy rule."
  value       = azurerm_policy_definition.policy.role_definition_ids
}

output "policy_definition" {
  description = "The full Azure Policy Definition resource object."
  value       = azurerm_policy_definition.policy
}
