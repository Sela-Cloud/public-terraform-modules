output "certificate_map_ids" {
  description = "Full resource name of each certificate map, keyed by resource name."
  value       = { for key, m in module.certificate_map : key => m.id }
}
