output "id" {
  description = "Full resource name of the secret version."
  value       = google_secret_manager_secret_version.this.id
}

output "version" {
  description = "The server-assigned version number."
  value       = google_secret_manager_secret_version.this.version
}
