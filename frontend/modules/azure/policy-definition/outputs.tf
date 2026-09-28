output "policy_definitions" {
  description = "A map of all created Azure Policy Definition module instances."
  value       = module.policy_definition
}

output "policy_definition_ids" {
  description = "A map of Policy Definition names to their respective resource IDs."
  value       = { for k, v in module.policy_definition : k => v.id }
}
