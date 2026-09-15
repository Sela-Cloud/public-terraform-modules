output "policy_ids" {
  description = "Full resource name of each policy, keyed by resource name."
  value       = { for key, p in module.service_connection_policy : key => p.id }
}

output "psc_connections" {
  description = "PSC connections created under each policy, keyed by resource name."
  value       = { for key, p in module.service_connection_policy : key => p.psc_connections }
}
