output "id" {
  description = "Full resource name of the cluster."
  value       = google_redis_cluster.this.id
}

output "discovery_endpoints" {
  description = "Endpoints for clients to connect to the cluster."
  value       = google_redis_cluster.this.discovery_endpoints
}

output "state" {
  description = "Current state of the cluster (CREATING, READY, UPDATING, DELETING, SUSPENDED)."
  value       = google_redis_cluster.this.state
}
