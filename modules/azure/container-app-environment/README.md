# Azure Container App Environment Terraform Child Module

Terraform module to provision an [Azure Container App Environment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment).

Azure Container App Environment provides the secure infrastructure boundary around one or more Container Apps, sharing a dedicated virtual network, log destination, and platform services.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.environment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Container App Environment. | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group where this Container App Environment exists. | `string` | n/a | yes |
| location | The Azure Region where this Container App Environment exists. | `string` | n/a | yes |
| log_analytics_workspace_id | ID of the linked Log Analytics workspace. | `string` | `null` | no |
| logs_destination | Storage destination for logs (`log-analytics`, `azure-monitor`, `none`). | `string` | `"log-analytics"` | no |
| infrastructure_subnet_id | Delegated Subnet ID for the environment. | `string` | `null` | no |
| infrastructure_resource_group_name | Name of the platform-managed resource group for infrastructure. | `string` | `null` | no |
| internal_load_balancer_enabled | Should the environment operate in internal load balancer mode? | `bool` | `false` | no |
| zone_redundancy_enabled | Should the environment be zone redundant? | `bool` | `false` | no |
| mutual_tls_enabled | Should mutual TLS (mTLS) be enabled? | `bool` | `false` | no |
| public_network_access | Public network access (`Enabled` or `Disabled`). | `string` | `"Enabled"` | no |
| dapr_application_insights_connection_string | Application Insights connection string for Dapr telemetry. | `string` | `null` | no |
| workload_profiles | Workload profile specifications. | `list(object)` | `[]` | no |
| identity | Managed Identity configuration block. | `object` | `null` | no |
| tags | A mapping of tags assigned to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Container App Environment. |
| name | The name of the Container App Environment. |
| resource_group_name | The name of the Resource Group. |
| location | The Azure Region. |
| default_domain | Default domain suffix for apps deployed in this environment. |
| static_ip_address | Static IP address assigned to the environment. |
| custom_domain_verification_id | Verification ID for custom domains. |
| docker_bridge_cidr | Internal Docker bridge network CIDR. |
| platform_reserved_cidr | Platform infrastructure services CIDR. |
| platform_reserved_dns_ip_address | Platform internal DNS IP address. |
| identity | Managed Service Identity configuration block. |
| container_app_environment | Full resource object. |

## Usage Examples

```hcl
module "container_app_environment" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/container-app-environment?ref=azure-container-app-environment"

  name                       = "cae-prod-eastus"
  resource_group_name        = "rg-apps-prod"
  location                   = "eastus"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs_destination           = "log-analytics"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
