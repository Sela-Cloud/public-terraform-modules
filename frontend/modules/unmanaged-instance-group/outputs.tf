output "unmanaged_instance_group_self_links" {
  description = "Self-link of each instance group, keyed by resource name. Use this as a load balancer backend."
  value       = { for key, umig in module.unmanaged_instance_group : key => umig.self_link }
}

output "unmanaged_instance_group_ids" {
  description = "Fully qualified ID of each instance group, keyed by resource name."
  value       = { for key, umig in module.unmanaged_instance_group : key => umig.id }
}
