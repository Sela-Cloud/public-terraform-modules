################################################################################
# Cluster General Configuration
################################################################################

variable "name" {
  description = "Name of the EKS cluster. Must be between 1 and 100 characters in length and only contain alphanumeric characters, hyphens, and underscores."
  type        = string
  default     = "eks-cluster"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,99}$", var.name))
    error_message = "The cluster name must be 1-100 characters, start with an alphanumeric character, and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "kubernetes_version" {
  description = "Desired Kubernetes version for your EKS cluster (e.g., '1.31', '1.30', '1.29'). If null, AWS defaults to the latest supported version."
  type        = string
  default     = "1.31"
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable. Valid values are 'api', 'audit', 'authenticator', 'controllerManager', 'scheduler'."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

################################################################################
# Networking & VPC
################################################################################

variable "vpc_id" {
  description = "VPC ID where the cluster and worker nodes will reside."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane and worker nodes can place ENIs. If empty, the module automatically discovers subnets from vpc_id or the default VPC."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.subnet_ids) == 0 || length(var.subnet_ids) >= 2
    error_message = "If provided, at least two subnet IDs in different Availability Zones must be specified."
  }
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs specifically for the EKS control plane ENIs. If empty, falls back to `subnet_ids`."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Indicates whether the Amazon EKS private API server endpoint is enabled. Default is true."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Indicates whether the Amazon EKS public API server endpoint is enabled. Default is true."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubernetes_network_config" {
  description = "Configuration block with network settings for the cluster (e.g. service_ipv4_cidr, ip_family)."
  type = object({
    service_ipv4_cidr = optional(string, null)
    ip_family         = optional(string, "ipv4")
  })
  default = null
}

variable "upgrade_policy_support_type" {
  description = "Support type to use for the cluster: 'STANDARD' or 'EXTENDED'."
  type        = string
  default     = null

  validation {
    condition     = var.upgrade_policy_support_type == null || contains(["STANDARD", "EXTENDED"], coalesce(var.upgrade_policy_support_type, "STANDARD"))
    error_message = "upgrade_policy_support_type must be either 'STANDARD' or 'EXTENDED'."
  }
}

variable "enable_zonal_shift" {
  description = "Whether to enable zonal shift for the EKS cluster."
  type        = bool
  default     = false
}

variable "bootstrap_self_managed_addons" {
  description = "Indicates whether default self-managed addons (kube-proxy, coredns, vpc-cni) are installed during cluster creation."
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of additional security group IDs to associate with the cluster control plane."
  type        = list(string)
  default     = []
}

variable "create_cluster_security_group" {
  description = "Whether to create a dedicated Security Group for the EKS Cluster control plane."
  type        = bool
  default     = true
}

################################################################################
# Cluster IAM Role
################################################################################

variable "create_iam_role" {
  description = "Whether to create a dedicated IAM role for the EKS cluster control plane."
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the EKS cluster control plane. Required if `create_iam_role` is false."
  type        = string
  default     = null
}

################################################################################
# Cluster Access & Authentication
################################################################################

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are 'CONFIG_MAP', 'API', or 'API_AND_CONFIG_MAP'. Default is 'API_AND_CONFIG_MAP'."
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of: 'CONFIG_MAP', 'API', 'API_AND_CONFIG_MAP'."
  }
}

variable "bootstrap_cluster_creator_admin_permissions" {
  description = "Whether to grant the IAM entity that creates the cluster administrative permissions via an EKS access entry."
  type        = bool
  default     = true
}

variable "access_entries" {
  description = "Map of EKS Access Entries to grant IAM roles or users direct access to the Kubernetes API."
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    user_name         = optional(string, null)
    kubernetes_groups = optional(list(string), [])
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string), [])
      })
    })), {})
  }))
  default = {}
}

################################################################################
# Encryption Configuration
################################################################################

variable "kms_key_arn" {
  description = "The ARN of an existing AWS KMS key to encrypt Kubernetes secrets. If provided, encryption for secrets will be enabled."
  type        = string
  default     = null
}

################################################################################
# OIDC / IRSA Configuration
################################################################################

variable "create_oidc_provider" {
  description = "Whether to create an IAM OpenID Connect (OIDC) provider for IAM Roles for Service Accounts (IRSA)."
  type        = bool
  default     = true
}

################################################################################
# Managed Node Groups
################################################################################

variable "create_node_iam_role" {
  description = "Whether to create a default IAM role for EKS Managed Node Groups."
  type        = bool
  default     = true
}

variable "node_iam_role_arn" {
  description = "Existing IAM role ARN for EKS Managed Node Groups. Required if `create_node_iam_role` is false."
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Map of EKS managed node group definitions to create."
  type = map(object({
    node_group_name        = optional(string, null)
    subnet_ids             = optional(list(string), null)
    instance_types         = optional(list(string), ["t3.medium"])
    capacity_type          = optional(string, "ON_DEMAND")
    disk_size              = optional(number, 20)
    ami_type               = optional(string, "AL2023_x86_64_STANDARD")
    node_role_arn          = optional(string, null)
    force_update_version   = optional(bool, false)
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
  }))
  default = {}
}

################################################################################
# EKS Addons
################################################################################

variable "cluster_addons" {
  description = "Map of EKS managed cluster addons to enable (e.g. vpc-cni, coredns, kube-proxy, eks-pod-identity-agent)."
  type = map(object({
    addon_name                  = string
    addon_version               = optional(string, null)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
    configuration_values        = optional(string, null)
    tags                        = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# EKS Pod Identity Associations
################################################################################

variable "pod_identity_associations" {
  description = "Map of EKS Pod Identity associations for binding IAM roles directly to Kubernetes service accounts (modern alternative to IRSA)."
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
  }))
  default = {}
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
