output "id" {
  description = "Full resource name of the secret."
  value       = google_secret_manager_secret.this.id
}

output "secret_id" {
  description = "Name of the secret."
  value       = google_secret_manager_secret.this.secret_id
}
