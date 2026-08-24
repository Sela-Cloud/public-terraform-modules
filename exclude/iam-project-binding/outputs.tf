output "project_bindings" {
  description = "The project ID each IAM binding was granted on, keyed by the configured resource key."
  value       = { for key, binding in module.iam_project_binding : key => binding.project_id }
}
