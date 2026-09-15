output "cluster_ids" {
  description = "Full resource name of each cluster, keyed by resource name."
  value       = { for key, c in module.redis_cluster : key => c.id }
}

output "discovery_endpoints" {
  description = "Client discovery endpoints for each cluster, keyed by resource name."
  value       = { for key, c in module.redis_cluster : key => c.discovery_endpoints }
}
