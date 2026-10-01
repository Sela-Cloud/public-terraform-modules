variable "name" {
  description = "(Required) The name of the Managed Kubernetes Cluster. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
  type        = string
}

variable "dns_prefix" {
  description = "(Optional) DNS prefix specified when creating the managed cluster. If not specified, defaults to the cluster name."
  type        = string
  default     = null
}

variable "dns_prefix_private_cluster" {
  description = "(Optional) Specifies the DNS prefix to use with private clusters. Mutually exclusive with dns_prefix."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes uptime SLA), and Premium. Defaults to Standard."
  type        = string
  default     = "Standard"
}

variable "automatic_upgrade_channel" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image, stable, and none. Defaults to patch."
  type        = string
  default     = "patch"
}

variable "node_os_upgrade_channel" {
  description = "(Optional) The upgrade channel for node OS security updates. Possible values are None, Unmanaged, SecurityPatch, NodeImage, and NodeImage-Managed."
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "(Optional) Should this Kubernetes Cluster have its API server address only resolvable inside a private network? Defaults to false."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "(Optional) Either the ID of Private DNS Zone which should be used to resolve the cluster FQDN, or System to use system-generated DNS zone."
  type        = string
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "(Optional) Specifies whether a public FQDN should be created for this private cluster. Defaults to false."
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-on be enabled on this Kubernetes Cluster? Defaults to false."
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL. Required for Workload Identity. Defaults to true."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Enable or Disable Workload Identity. Defaults to true."
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "(Optional) If true, local administrator accounts will be disabled. Defaults to false."
  type        = bool
  default     = false
}

variable "role_based_access_control_enabled" {
  description = "(Optional) Whether Role Based Access Control for the Kubernetes Cluster should be enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "identity_type" {
  description = "(Optional) The type of Managed Identity that should be assigned to this Kubernetes Cluster. Possible values are SystemAssigned or UserAssigned. Defaults to SystemAssigned."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster. Required if identity_type is UserAssigned."
  type        = list(string)
  default     = null
}

variable "default_node_pool" {
  description = "(Optional) Configuration for the default primary system node pool."
  type = object({
    name                 = optional(string, "system")
    vm_size              = optional(string, "Standard_D2s_v5")
    auto_scaling_enabled = optional(bool, true)
    node_count           = optional(number, null)
    min_count            = optional(number, 1)
    max_count            = optional(number, 3)
    os_disk_size_gb      = optional(number, 128)
    os_disk_type         = optional(string, "Managed")
    os_sku               = optional(string, "Ubuntu")
    vnet_subnet_id       = optional(string, null)
    zones                = optional(list(string), ["1", "2", "3"])
    max_pods             = optional(number, null)
    node_labels          = optional(map(string), {})
    tags                 = optional(map(string), {})
  })
  default = {
    name                 = "system"
    vm_size              = "Standard_D2s_v5"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    os_disk_size_gb      = 128
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    zones                = ["1", "2", "3"]
  }
}

variable "network_profile" {
  description = "(Optional) Network profile block for AKS cluster networking configuration."
  type = object({
    network_plugin     = optional(string, "azure")
    network_policy     = optional(string, "azure")
    network_data_plane = optional(string, null)
    dns_service_ip     = optional(string, null)
    service_cidr       = optional(string, null)
    pod_cidr           = optional(string, null)
    load_balancer_sku  = optional(string, "standard")
    outbound_type      = optional(string, "loadBalancer")
  })
  default = {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "(Optional) The IP ranges to allow for incoming traffic to the API server."
  type        = set(string)
  default     = null
}

variable "azure_active_directory_role_based_access_control" {
  description = "(Optional) Azure Active Directory Role Based Access Control configuration."
  type = object({
    azure_rbac_enabled     = optional(bool, true)
    tenant_id              = optional(string, null)
    admin_group_object_ids = optional(list(string), null)
  })
  default = null
}

variable "log_analytics_workspace_id" {
  description = "(Optional) The ID of the Log Analytics Workspace for Container Insights OMS agent integration."
  type        = string
  default     = null
}

variable "key_vault_secrets_provider" {
  description = "(Optional) Key Vault Secrets Provider block configuration for Azure Key Vault CSI driver."
  type = object({
    secret_rotation_enabled  = optional(bool, true)
    secret_rotation_interval = optional(string, "2m")
  })
  default = null
}

variable "node_pools" {
  description = "(Optional) Map of additional worker/user node pools to create."
  type = map(object({
    name                 = optional(string, null)
    vm_size              = string
    auto_scaling_enabled = optional(bool, true)
    node_count           = optional(number, null)
    min_count            = optional(number, 1)
    max_count            = optional(number, 5)
    mode                 = optional(string, "User")
    priority             = optional(string, "Regular")
    eviction_policy      = optional(string, null)
    spot_max_price       = optional(number, null)
    os_disk_size_gb      = optional(number, 128)
    os_disk_type         = optional(string, "Managed")
    os_sku               = optional(string, "Ubuntu")
    os_type              = optional(string, "Linux")
    vnet_subnet_id       = optional(string, null)
    pod_subnet_id        = optional(string, null)
    zones                = optional(list(string), ["1", "2", "3"])
    max_pods             = optional(number, null)
    node_labels          = optional(map(string), {})
    node_taints          = optional(list(string), [])
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
