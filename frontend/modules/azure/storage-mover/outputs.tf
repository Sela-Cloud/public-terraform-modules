output "storage_movers" {
  description = "A map of all created Azure Storage Mover module instances."
  value       = module.storage_mover
}

output "storage_mover_ids" {
  description = "A map of storage mover names to their resource IDs."
  value       = { for k, v in module.storage_mover : k => v.id }
}
