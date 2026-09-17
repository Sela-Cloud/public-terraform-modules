output "node_pools" {
  description = "Node-pool IDs keyed by the configured resource key."
  value       = { for key, node_pool in module.gke_standard_node_pool : key => node_pool.id }
}
