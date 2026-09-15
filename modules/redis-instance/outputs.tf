output "id" {
  description = "Full resource name of the instance."
  value       = google_redis_instance.this.id
}

output "host" {
  description = "Hostname or IP address of the exposed Redis endpoint."
  value       = google_redis_instance.this.host
}

output "port" {
  description = "Port number of the exposed Redis endpoint."
  value       = google_redis_instance.this.port
}

output "read_endpoint" {
  description = "Hostname or IP address of the read-only endpoint. Standard tier only."
  value       = google_redis_instance.this.read_endpoint
}

output "auth_string" {
  description = "AUTH string for the instance, if auth_enabled is true."
  value       = google_redis_instance.this.auth_string
  sensitive   = true
}
