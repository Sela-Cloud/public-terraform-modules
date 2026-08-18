output "autopilot_clusters" {
  description = "Autopilot cluster IDs keyed by the configured resource key."
  value       = { for key, cluster in module.gke_autopilot : key => cluster.id }
}
