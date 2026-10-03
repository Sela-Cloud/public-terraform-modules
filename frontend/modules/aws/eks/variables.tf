variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "eks" {
  description = "Map of EKS cluster configurations to deploy, keyed by cluster name."
  type = map(object({
    name                                        = optional(string, "eks-cluster")
    kubernetes_version                          = optional(string, "1.31")
    vpc_id                                      = optional(string, null)
    subnet_ids                                  = optional(list(string), [])
    control_plane_subnet_ids                    = optional(list(string), [])
    endpoint_private_access                     = optional(bool, true)
    endpoint_public_access                      = optional(bool, true)
    public_access_cidrs                         = optional(list(string), ["0.0.0.0/0"])
    kubernetes_network_config = optional(object({
      service_ipv4_cidr = optional(string, null)
      ip_family         = optional(string, "ipv4")
    }), null)
    upgrade_policy_support_type                 = optional(string, null)
    enable_zonal_shift                          = optional(bool, false)
    bootstrap_self_managed_addons               = optional(bool, true)
    security_group_ids                          = optional(list(string), [])
    create_cluster_security_group               = optional(bool, true)
    create_iam_role                             = optional(bool, true)
    iam_role_arn                                = optional(string, null)
    enabled_cluster_log_types                   = optional(list(string), ["api", "audit", "authenticator", "controllerManager", "scheduler"])
    authentication_mode                         = optional(string, "API_AND_CONFIG_MAP")
    bootstrap_cluster_creator_admin_permissions = optional(bool, true)
    kms_key_arn                                 = optional(string, null)
    create_oidc_provider                        = optional(bool, true)
    create_node_iam_role                        = optional(bool, true)
    node_iam_role_arn                           = optional(string, null)
    node_groups = optional(map(object({
      node_group_name      = optional(string, null)
      subnet_ids           = optional(list(string), null)
      instance_types       = optional(list(string), ["t3.medium"])
      capacity_type        = optional(string, "ON_DEMAND")
      disk_size            = optional(number, 20)
      ami_type             = optional(string, "AL2023_x86_64_STANDARD")
      node_role_arn        = optional(string, null)
      force_update_version = optional(bool, false)
      scaling_config = optional(object({
        desired_size = optional(number, 2)
        max_size     = optional(number, 5)
        min_size     = optional(number, 1)
      }), {})
      update_config = optional(object({
        max_unavailable            = optional(number, null)
        max_unavailable_percentage = optional(number, null)
      }), {
        max_unavailable = 1
      })
      labels = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = optional(string, null)
        effect = string
      })), [])
      launch_template = optional(object({
        id      = optional(string, null)
        name    = optional(string, null)
        version = optional(string, "$Latest")
      }), null)
      remote_access = optional(object({
        ec2_ssh_key               = optional(string, null)
        source_security_group_ids = optional(list(string), null)
      }), null)
      tags = optional(map(string), {})
    })), {})
    cluster_addons = optional(map(object({
      addon_name                  = string
      addon_version               = optional(string, null)
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      service_account_role_arn    = optional(string, null)
      configuration_values        = optional(string, null)
      tags                        = optional(map(string), {})
    })), {})
    pod_identity_associations = optional(map(object({
      namespace       = string
      service_account = string
      role_arn        = string
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
