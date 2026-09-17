output "id" {
  description = "Fully qualified GKE cluster ID."
  value       = google_container_cluster.this.id
}

output "name" {
  description = "GKE cluster name."
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "GKE control-plane endpoint."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}
