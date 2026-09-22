output "virtual_machines" {
  description = "Map of created Virtual Machines and their attributes."
  value       = module.virtual_machine
}

output "virtual_machine_ids" {
  description = "Map of Virtual Machine names to their Azure resource IDs."
  value       = { for k, v in module.virtual_machine : k => v.id }
}
