# Azure NAT Gateway Terraform Child Module

Terraform module to provision an [Azure NAT Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway).

This module manages the Azure NAT Gateway resource (`azurerm_nat_gateway`), which provides outbound internet connectivity for one or more subnets within an Azure Virtual Network.

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
| [azurerm_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the NAT Gateway. Changing this forces a new resource to be created. | `string` | `"ng-default"` | no |
| resource_group_name | The name of the Resource Group in which to create the NAT Gateway. | `string` | `"rg-default"` | no |
| location | The Azure Region where the NAT Gateway should exist. | `string` | `"eastus"` | no |
| sku_name | The SKU which should be used for the NAT Gateway. Supported value is `Standard`. | `string` | `"Standard"` | no |
| idle_timeout_in_minutes | The idle timeout in minutes for TCP connections (between 4 and 120). | `number` | `4` | no |
| zones | A list of Availability Zones in which this NAT Gateway should be located (at most one zone). Leave `null` for a regional gateway. | `list(string)` | `null` | no |
| tags | A mapping of tags which should be assigned to the NAT Gateway. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the NAT Gateway. |
| name | The Name of the NAT Gateway. |
| resource_group_name | The name of the Resource Group in which the NAT Gateway was created. |
| location | The Azure Region of the NAT Gateway. |
| resource_guid | The resource GUID property of the NAT Gateway. |
| sku_name | The SKU of the NAT Gateway. |
| idle_timeout_in_minutes | The idle timeout in minutes for the NAT Gateway. |
| zones | The Availability Zones associated with the NAT Gateway. |
| tags | The tags assigned to the NAT Gateway. |
| nat_gateway | The full Azure NAT Gateway resource object. |

## Usage

```hcl
module "nat_gateway" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/nat-gateway?ref=v0.7.6"

  name                    = "ng-workload-prod"
  resource_group_name     = "rg-workload-prod"
  location                = "eastus"
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
