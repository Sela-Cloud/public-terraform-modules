resource "google_secret_manager_secret_version" "this" {
  secret      = "projects/${var.project_id}/secrets/${var.secret_name}"
  secret_data = var.secret_data
  enabled     = var.enabled
}
