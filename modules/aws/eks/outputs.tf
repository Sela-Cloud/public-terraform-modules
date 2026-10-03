################################################################################
# Cluster Outputs
################################################################################

output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster."
  value       = aws_eks_cluster.this.version
}

output "cluster_platform_version" {
  description = "Platform version for the cluster."
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster."
  value       = aws_eks_cluster.this.status
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster control plane."
  value       = var.create_iam_role ? aws_iam_role.cluster[0].arn : var.iam_role_arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster control plane."
  value       = var.create_iam_role ? aws_iam_role.cluster[0].name : null
}

################################################################################
# OIDC / IRSA Outputs
################################################################################

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if IRSA is enabled."
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : null
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider without protocol (e.g. oidc.eks.<region>.amazonaws.com/id/<id>)."
  value       = var.create_oidc_provider ? replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "") : null
}

################################################################################
# Node Group Outputs
################################################################################

output "node_groups" {
  description = "Map of created EKS node groups and their attributes."
  value = {
    for k, ng in aws_eks_node_group.this : k => {
      id            = ng.id
      arn           = ng.arn
      status        = ng.status
      capacity_type = ng.capacity_type
    }
  }
}

output "node_iam_role_arn" {
  description = "Default IAM role ARN created for the worker node groups."
  value       = var.create_node_iam_role && length(var.node_groups) > 0 ? aws_iam_role.node[0].arn : var.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "Default IAM role name created for the worker node groups."
  value       = var.create_node_iam_role && length(var.node_groups) > 0 ? aws_iam_role.node[0].name : null
}

################################################################################
# Addon Outputs
################################################################################

output "cluster_addons" {
  description = "Map of EKS addons created for the cluster."
  value = {
    for k, a in aws_eks_addon.this : k => {
      arn           = a.arn
      addon_name    = a.addon_name
      addon_version = a.addon_version
    }
  }
}

output "cluster_service_cidr" {
  description = "The CIDR block to assign Kubernetes pod and service IP addresses from."
  value       = try(aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr, null)
}

output "cluster_ip_family" {
  description = "The IP family used by the cluster (ipv4 or ipv6)."
  value       = try(aws_eks_cluster.this.kubernetes_network_config[0].ip_family, "ipv4")
}

output "pod_identity_associations" {
  description = "Map of created EKS Pod Identity associations."
  value = {
    for k, p in aws_eks_pod_identity_association.this : k => {
      arn             = p.arn
      association_id  = p.association_id
      namespace       = p.namespace
      service_account = p.service_account
      role_arn        = p.role_arn
    }
  }
}

