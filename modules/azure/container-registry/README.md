# Azure Container Registry Terraform Child Module

Terraform module to provision an [Azure Container Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry).

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
| [azurerm_container_registry.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Container Registry. Only alphanumeric characters allowed. Must be globally unique. | `string` | `"crdefault123"` | no |
| resource_group_name | The name of the Resource Group in which to create the Container Registry. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Container Registry should exist. | `string` | `"eastus"` | no |
| sku | The SKU name of the container registry. Possible values are 'Basic', 'Standard', and 'Premium'. | `string` | `"Standard"` | no |
| admin_enabled | Specifies whether the admin user is enabled. | `bool` | `false` | no |
| public_network_access_enabled | Whether public network access is allowed for the container registry. | `bool` | `true` | no |
| network_rule_bypass_option | Whether to allow trusted Azure services to access a network restricted Container Registry. Possible values are 'AzureServices' and 'None'. | `string` | `"AzureServices"` | no |
| zone_redundancy_enabled | Whether zone redundancy is enabled for this Container Registry. Only supported on Premium SKU. | `bool` | `false` | no |
| anonymous_pull_enabled | Whether anonymous (unauthenticated) pull access is allowed. Only supported on Standard and Premium SKU. | `bool` | `false` | no |
| data_endpoint_enabled | Whether to enable dedicated data endpoints for this Container Registry. Only supported on Premium SKU. | `bool` | `false` | no |
| export_policy_enabled | Boolean value that indicates whether export policy is enabled. | `bool` | `true` | no |
| quarantine_policy_enabled | Boolean value that indicates whether quarantine policy is enabled. Only supported on Premium SKU. | `bool` | `false` | no |
| retention_policy_in_days | The number of days to retain untagged manifests after which they are purged. Only supported on Premium SKU. | `number` | `null` | no |
| trust_policy_enabled | Boolean value that indicates whether the policy is enabled for content trust. Only supported on Premium SKU. | `bool` | `false` | no |
| identity | Managed Identity configuration block for the Container Registry. | <pre>object({<br>  type         = string<br>  identity_ids = optional(list(string), null)<br>})</pre> | `null` | no |
| georeplications | A list of geo-replication configurations for the Container Registry. Only supported on Premium SKU. | <pre>list(object({<br>  location                  = string<br>  regional_endpoint_enabled = optional(bool, null)<br>  zone_redundancy_enabled   = optional(bool, null)<br>  tags                      = optional(map(string), {})<br>}))</pre> | `[]` | no |
| network_rule_set | Network rule set configuration block for the Container Registry. Only supported on Premium SKU. | <pre>object({<br>  default_action = optional(string, "Allow")<br>  ip_rule = optional(list(object({<br>    action   = string<br>    ip_range = string<br>  })), [])<br>})</pre> | `null` | no |
| tags | A mapping of tags which should be assigned to the Container Registry. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Container Registry. |
| name | The Name of the Container Registry. |
| login_server | The URL that can be used to log into the container registry. |
| admin_username | The Username associated with the Container Registry Admin account. |
| admin_password | The Password associated with the Container Registry Admin account (sensitive). |
| resource_group_name | The Name of the Resource Group in which the Container Registry was created. |
| location | The Azure Region of the Container Registry. |
| sku | The SKU of the Container Registry. |
| admin_enabled | Whether the admin user is enabled for the Container Registry. |
| tags | The tags assigned to the Container Registry. |
| container_registry | The full Azure Container Registry resource object (sensitive). |

## Usage

### Standard SKU Registry

```hcl
module "container_registry" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/container-registry?ref=v0.7.6"

  name                = "mysecureacr123"
  resource_group_name = "rg-acr-prod"
  location            = "eastus"
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Premium SKU Registry with Geo-Replication and Zone Redundancy

```hcl
module "container_registry_premium" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/container-registry?ref=v0.7.6"

  name                    = "myprodacr123"
  resource_group_name     = "rg-acr-prod"
  location                = "eastus"
  sku                     = "Premium"
  admin_enabled           = false
  zone_redundancy_enabled = true

  georeplications = [
    {
      location                = "westeurope"
      zone_redundancy_enabled = true
      tags = {
        Region = "Europe"
      }
    }
  ]

  tags = {
    Environment = "production"
  }
}
```
