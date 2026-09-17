# Azure Resource Group Terraform Child Module

Terraform module to provision an [Azure Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group.html).

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
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The Name which should be used for this Resource Group. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Resource Group should exist. | `string` | `"eastus"` | no |
| tags | A mapping of tags which should be assigned to the Resource Group. | `map(string)` | `{}` | no |
| managed_by | The ID of the resource or application that manages this Resource Group. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Resource Group. |
| name | The Name of the Resource Group. |
| location | The Azure Region of the Resource Group. |
| resource_group | The full Azure Resource Group resource object. |

## Usage

```hcl
module "resource_group" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/resource-group?ref=v0.7.6"

  name     = "rg-workload-prod"
  location = "eastus"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
