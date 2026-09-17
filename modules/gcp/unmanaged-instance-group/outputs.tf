output "id" {
  description = "an identifier for the resource with format projects/{{project}}/zones/{{zone}}/instanceGroups/{{name}}"
  value       = google_compute_instance_group.umig.id
}

output "self_link" {
  description = "The URI of the created resource."
  value       = google_compute_instance_group.umig.self_link
}
