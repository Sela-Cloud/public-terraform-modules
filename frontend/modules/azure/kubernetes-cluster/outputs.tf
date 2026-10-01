output "kubernetes_clusters" {
  description = "A map of all created Azure Kubernetes Cluster module instances."
  value       = module.kubernetes_cluster
  sensitive   = true
}

output "kubernetes_cluster_ids" {
  description = "A map of cluster names to their resource IDs."
  value       = { for k, v in module.kubernetes_cluster : k => v.id }
}

output "kubernetes_cluster_fqdns" {
  description = "A map of cluster names to their FQDNs."
  value       = { for k, v in module.kubernetes_cluster : k => v.fqdn }
}

output "kubernetes_cluster_oidc_issuer_urls" {
  description = "A map of cluster names to their OIDC issuer URLs."
  value       = { for k, v in module.kubernetes_cluster : k => v.oidc_issuer_url }
}
