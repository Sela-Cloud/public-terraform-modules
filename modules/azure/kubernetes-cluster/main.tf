resource "azurerm_kubernetes_cluster" "this" {
  name                                = var.name
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  dns_prefix                          = var.dns_prefix != null ? var.dns_prefix : (var.private_cluster_enabled && var.dns_prefix_private_cluster != null ? null : var.name)
  dns_prefix_private_cluster          = var.dns_prefix_private_cluster
  kubernetes_version                  = var.kubernetes_version
  sku_tier                            = var.sku_tier
  automatic_upgrade_channel           = var.automatic_upgrade_channel
  node_os_upgrade_channel             = var.node_os_upgrade_channel
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  azure_policy_enabled                = var.azure_policy_enabled
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  local_account_disabled              = var.local_account_disabled
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  tags                                = var.tags

  default_node_pool {
    name                 = var.default_node_pool.name
    vm_size              = var.default_node_pool.vm_size
    auto_scaling_enabled = var.default_node_pool.auto_scaling_enabled
    node_count           = var.default_node_pool.auto_scaling_enabled ? null : var.default_node_pool.node_count
    min_count            = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.min_count : null
    max_count            = var.default_node_pool.auto_scaling_enabled ? var.default_node_pool.max_count : null
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    os_disk_type         = var.default_node_pool.os_disk_type
    os_sku               = var.default_node_pool.os_sku
    vnet_subnet_id       = var.default_node_pool.vnet_subnet_id
    zones                = var.default_node_pool.zones
    max_pods             = var.default_node_pool.max_pods
    node_labels          = var.default_node_pool.node_labels
    tags                 = var.default_node_pool.tags
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
  }

  dynamic "network_profile" {
    for_each = var.network_profile != null ? [var.network_profile] : []
    content {
      network_plugin     = network_profile.value.network_plugin
      network_policy     = network_profile.value.network_policy
      network_data_plane = network_profile.value.network_data_plane
      dns_service_ip     = network_profile.value.dns_service_ip
      service_cidr       = network_profile.value.service_cidr
      pod_cidr           = network_profile.value.pod_cidr
      load_balancer_sku  = network_profile.value.load_balancer_sku
      outbound_type      = network_profile.value.outbound_type
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control != null ? [var.azure_active_directory_role_based_access_control] : []
    content {
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                  = coalesce(each.value.name, each.key)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  node_count            = each.value.auto_scaling_enabled ? null : each.value.node_count
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
  mode                  = each.value.mode
  priority              = each.value.priority
  eviction_policy       = each.value.priority == "Spot" ? each.value.eviction_policy : null
  spot_max_price        = each.value.priority == "Spot" ? each.value.spot_max_price : null
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_sku                = each.value.os_sku
  os_type               = each.value.os_type
  vnet_subnet_id        = each.value.vnet_subnet_id
  pod_subnet_id         = each.value.pod_subnet_id
  zones                 = each.value.zones
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  tags                  = each.value.tags
}
