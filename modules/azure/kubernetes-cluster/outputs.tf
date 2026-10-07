output "id" {
  description = "The Kubernetes Managed Cluster ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "private_fqdn" {
  description = "The FQDN for the Kubernetes Cluster when private cluster is enabled."
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "portal_fqdn" {
  description = "The FQDN for the Azure Portal resources when private cluster is enabled."
  value       = azurerm_kubernetes_cluster.this.portal_fqdn
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "identity" {
  description = "The Managed Identity block for the Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.this.identity
}

output "kube_config" {
  description = "A kube_config block representing cluster credentials."
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "A kube_admin_config block representing cluster admin credentials."
  value       = azurerm_kubernetes_cluster.this.kube_admin_config
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw Kubernetes admin config to be used by kubectl and other compatible tools."
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive   = true
}

output "node_pools" {
  description = "A map of all created additional node pools."
  value = {
    for k, v in azurerm_kubernetes_cluster_node_pool.this : k => {
      id                   = v.id
      name                 = v.name
      vm_size              = v.vm_size
      node_count           = v.node_count
      auto_scaling_enabled = v.auto_scaling_enabled
      min_count            = v.min_count
      max_count            = v.max_count
      mode                 = v.mode
      priority             = v.priority
    }
  }
}
