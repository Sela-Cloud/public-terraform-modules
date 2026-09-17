output "autopilot_clusters" {
  description = "Autopilot cluster IDs keyed by the configured resource key."
  value       = { for key, cluster in module.gke_autopilot : key => cluster.id }
}

output "standard_clusters" {
  description = "Standard cluster IDs keyed by the configured resource key."
  value       = { for key, cluster in module.gke_standard_cluster : key => cluster.id }
}

output "standard_node_pools" {
  description = "Standard node-pool IDs keyed by cluster and node-pool name."
  value       = { for key, node_pool in module.gke_standard_node_pool : key => node_pool.id }
}
