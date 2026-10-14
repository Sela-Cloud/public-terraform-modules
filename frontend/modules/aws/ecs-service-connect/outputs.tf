output "namespace_arns" {
  description = "ARN of each namespace, keyed by name. Use it as a cluster's default namespace or a service's Service Connect namespace."
  value       = { for k, ns in module.ecs_service_connect : k => ns.arn }
}
