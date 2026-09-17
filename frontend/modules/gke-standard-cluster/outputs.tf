output "standard_clusters" {
  description = "Standard cluster IDs keyed by the configured resource key."
  value       = { for key, cluster in module.gke_standard_cluster : key => cluster.id }
}
