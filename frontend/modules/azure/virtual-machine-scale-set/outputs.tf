output "virtual_machine_scale_sets" {
  description = "Map of created Virtual Machine Scale Sets and their attributes."
  value       = module.virtual_machine_scale_set
}

output "virtual_machine_scale_set_ids" {
  description = "Map of Virtual Machine Scale Set names to their Azure resource IDs."
  value       = { for k, v in module.virtual_machine_scale_set : k => v.id }
}

output "identities" {
  description = "Map of Virtual Machine Scale Set names to their managed service identity blocks."
  value       = { for k, v in module.virtual_machine_scale_set : k => v.identity }
}
