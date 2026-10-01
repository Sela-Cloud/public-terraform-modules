variable "kubernetes_cluster" {
  description = "Map of Azure Kubernetes Service (AKS) cluster configurations."
  type = map(object({
    name                                = string
    resource_group_name                 = string
    location                            = string
    dns_prefix                          = optional(string, null)
    dns_prefix_private_cluster          = optional(string, null)
    kubernetes_version                  = optional(string, null)
    sku_tier                            = optional(string, "Standard")
    automatic_upgrade_channel           = optional(string, "patch")
    node_os_upgrade_channel             = optional(string, null)
    private_cluster_enabled             = optional(bool, false)
    private_dns_zone_id                 = optional(string, null)
    private_cluster_public_fqdn_enabled = optional(bool, false)
    azure_policy_enabled                = optional(bool, false)
    oidc_issuer_enabled                 = optional(bool, true)
    workload_identity_enabled           = optional(bool, true)
    local_account_disabled              = optional(bool, false)
    role_based_access_control_enabled   = optional(bool, true)
    identity_type                       = optional(string, "SystemAssigned")
    identity_ids                        = optional(list(string), null)

    default_node_pool = optional(object({
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
      }), {
      name                 = "system"
      vm_size              = "Standard_D2s_v5"
      auto_scaling_enabled = true
      min_count            = 1
      max_count            = 3
      os_disk_size_gb      = 128
      os_disk_type         = "Managed"
      os_sku               = "Ubuntu"
      zones                = ["1", "2", "3"]
    })

    network_profile = optional(object({
      network_plugin     = optional(string, "azure")
      network_policy     = optional(string, "azure")
      network_data_plane = optional(string, null)
      dns_service_ip     = optional(string, null)
      service_cidr       = optional(string, null)
      pod_cidr           = optional(string, null)
      load_balancer_sku  = optional(string, "standard")
      outbound_type      = optional(string, "loadBalancer")
      }), {
      network_plugin    = "azure"
      network_policy    = "azure"
      load_balancer_sku = "standard"
      outbound_type     = "loadBalancer"
    })

    api_server_authorized_ip_ranges = optional(set(string), null)

    azure_active_directory_role_based_access_control = optional(object({
      azure_rbac_enabled     = optional(bool, true)
      tenant_id              = optional(string, null)
      admin_group_object_ids = optional(list(string), null)
    }), null)

    log_analytics_workspace_id = optional(string, null)

    key_vault_secrets_provider = optional(object({
      secret_rotation_enabled  = optional(bool, true)
      secret_rotation_interval = optional(string, "2m")
    }), null)

    node_pools = optional(map(object({
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
    })), {})

    tags = optional(map(string), {})
  }))
  default = {}
}
