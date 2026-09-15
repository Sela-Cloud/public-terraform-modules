resource "google_network_connectivity_service_connection_policy" "this" {
  project       = var.project_id
  name          = var.name
  location      = var.location
  network       = var.network
  description   = var.description
  labels        = var.labels
  service_class = var.service_class

  psc_config {
    subnetworks = var.subnetworks
    limit       = var.psc_connection_limit == null ? null : tostring(var.psc_connection_limit)
  }
}
