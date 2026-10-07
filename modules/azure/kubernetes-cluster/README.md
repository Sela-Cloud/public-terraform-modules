# Azure Kubernetes Service (AKS) Terraform Child Module

Terraform module to provision an [Azure Kubernetes Service (AKS) Managed Cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) with system node pool, additional user/workload node pools, advanced networking, managed identities, and enterprise security integrations.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.100.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.100.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Managed Kubernetes Cluster. | `string` | n/a | yes |
| resource_group_name | Specifies the Resource Group where the Managed Kubernetes Cluster should exist. | `string` | n/a | yes |
| location | The Azure Region where the Managed Kubernetes Cluster should exist. | `string` | n/a | yes |
| dns_prefix | DNS prefix specified when creating the managed cluster (defaults to cluster name). | `string` | `null` | no |
| dns_prefix_private_cluster | Specifies the DNS prefix to use with private clusters. | `string` | `null` | no |
| kubernetes_version | Version of Kubernetes specified when creating the AKS managed cluster. | `string` | `null` | no |
| sku_tier | The SKU Tier (`Free`, `Standard`, `Premium`). | `string` | `"Standard"` | no |
| automatic_upgrade_channel | The upgrade channel (`patch`, `rapid`, `node-image`, `stable`, `none`). | `string` | `"patch"` | no |
| node_os_upgrade_channel | The upgrade channel for node OS security updates. | `string` | `null` | no |
| private_cluster_enabled | Should this Kubernetes Cluster have private API server endpoint? | `bool` | `false` | no |
| private_dns_zone_id | ID of Private DNS Zone for private cluster FQDN resolution. | `string` | `null` | no |
| private_cluster_public_fqdn_enabled | Specifies whether a public FQDN should be created for private cluster. | `bool` | `false` | no |
| azure_policy_enabled | Should the Azure Policy Add-on be enabled? | `bool` | `false` | no |
| oidc_issuer_enabled | Enable OIDC issuer URL for Workload Identity. | `bool` | `true` | no |
| workload_identity_enabled | Enable Workload Identity on the cluster. | `bool` | `true` | no |
| local_account_disabled | If true, local administrator accounts will be disabled. | `bool` | `false` | no |
| role_based_access_control_enabled | Whether Role Based Access Control should be enabled. | `bool` | `true` | no |
| identity_type | Managed Identity type (`SystemAssigned` or `UserAssigned`). | `string` | `"SystemAssigned"` | no |
| identity_ids | List of User Assigned Identity IDs when using `UserAssigned`. | `list(string)` | `null` | no |
| default_node_pool | Configuration for the default primary system node pool. | `object` | See variables | no |
| network_profile | Network profile block (CNI plugin, policy, CIDRs, LB SKU). | `object` | See variables | no |
| api_server_authorized_ip_ranges | Set of IP ranges authorized to communicate with API server. | `set(string)` | `null` | no |
| azure_active_directory_role_based_access_control | Entra ID (Azure AD) RBAC configuration block. | `object` | `null` | no |
| log_analytics_workspace_id | Resource ID of Log Analytics workspace for Container Insights. | `string` | `null` | no |
| key_vault_secrets_provider | Azure Key Vault Secrets Store CSI driver configuration. | `object` | `null` | no |
| node_pools | Map of additional user/worker node pools to create. | `map(object)` | `{}` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The Kubernetes Managed Cluster ID. |
| name | The name of the Managed Kubernetes Cluster. |
| fqdn | The FQDN of the Azure Kubernetes Managed Cluster. |
| private_fqdn | The FQDN for the Kubernetes Cluster when private cluster is enabled. |
| portal_fqdn | The FQDN for the Azure Portal resources when private cluster is enabled. |
| oidc_issuer_url | The OIDC issuer URL associated with the cluster. |
| node_resource_group | The auto-generated Resource Group containing VM scale sets and nodes. |
| identity | The Managed Identity block for the Kubernetes Cluster. |
| kube_config | Structured kube_config block (sensitive). |
| kube_config_raw | Raw Kubernetes kubeconfig YAML string (sensitive). |
| kube_admin_config | Structured kube_admin_config block (sensitive). |
| kube_admin_config_raw | Raw Kubernetes admin kubeconfig YAML string (sensitive). |
| node_pools | Map of all created additional node pools. |

## Usage Examples

### Production Cluster with Workload Identity and Additional Worker Pool

```hcl
module "aks_cluster" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/kubernetes-cluster?ref=azure-wip"

  name                = "aks-prod-eastus"
  resource_group_name = "rg-prod-containers"
  location            = "eastus"
  dns_prefix          = "aks-prod-eastus"
  sku_tier            = "Standard"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D4s_v5"
    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 5
    os_disk_size_gb      = 128
    zones                = ["1", "2", "3"]
  }

  network_profile = {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  node_pools = {
    "workload" = {
      vm_size              = "Standard_D8s_v5"
      auto_scaling_enabled = true
      min_count            = 2
      max_count            = 10
      mode                 = "User"
      priority             = "Regular"
      zones                = ["1", "2", "3"]
      node_labels = {
        "workload" = "general"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
