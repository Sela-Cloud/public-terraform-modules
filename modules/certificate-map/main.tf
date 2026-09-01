resource "google_certificate_manager_certificate_map" "this" {
  project     = var.project_id
  name        = var.name
  description = var.description
}

resource "google_certificate_manager_certificate_map_entry" "entries" {
  for_each = var.entries

  project     = var.project_id
  name        = each.key
  map         = google_certificate_manager_certificate_map.this.name
  description = each.value.description
  hostname    = each.value.is_primary ? null : each.value.hostname
  matcher     = each.value.is_primary ? "PRIMARY" : null
  labels      = each.value.labels

  certificates = [
    for cert_name in each.value.certificates :
    "projects/${var.project_id}/locations/global/certificates/${cert_name}"
  ]
}
