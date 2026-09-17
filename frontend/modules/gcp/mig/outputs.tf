output "mig_self_links" {
  description = "Self-link of each managed instance group, keyed by resource name."
  value       = { for key, mig in module.mig : key => mig.self_link }
}

output "mig_instance_groups" {
  description = "Instance group URL of each managed instance group, keyed by resource name. Use this as a load balancer backend."
  value       = { for key, mig in module.mig : key => mig.instance_group }
}

output "mig_health_check_self_links" {
  description = "Self-links of the health checks created for each managed instance group, keyed by resource name."
  value       = { for key, mig in module.mig : key => mig.health_check_self_links }
}
