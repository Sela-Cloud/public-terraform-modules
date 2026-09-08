resource "google_compute_instance_group" "umig" {
  name        = var.name
  description = var.description
  project     = var.project_id
  zone        = var.zone

  # Optional and computed: with no network given Compute Engine infers it from the members.
  # Building the URL unconditionally would send "projects/<p>/global/networks/" for an unset
  # network, which is not a valid reference.
  network = try(trimspace(var.network), "") != "" ? "projects/${var.project_id}/global/networks/${var.network}" : null

  # The group is addressed by instance name; the API wants a URL per member.
  instances = [
    for instance in var.instances :
    "projects/${var.project_id}/zones/${var.zone}/instances/${instance}"
  ]

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}
