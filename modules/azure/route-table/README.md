# Azure Route Table Terraform Child Module

Terraform module to provision an [Azure Route Table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table).

This module manages the Azure Route Table resource with support for inline user-defined routes (UDRs), BGP route propagation control, resource tagging, and optional subnet associations.

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
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_route_table_association.subnet_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Route Table. Changing this forces a new resource to be created. | `string` | `"rt-default"` | no |
| resource_group_name | The name of the resource group in which to create the Route Table. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Route Table should exist. | `string` | `"eastus"` | no |
| bgp_route_propagation_enabled | Boolean flag which controls propagation of routes learned by BGP on that route table. | `bool` | `true` | no |
| routes | List of route objects representing inline routes to be created with the Route Table. | `list(object)` | `[]` | no |
| subnet_ids | Optional list of Subnet IDs to associate with this Route Table. | `list(string)` | `[]` | no |
| tags | A mapping of tags which should be assigned to the Route Table. | `map(string)` | `{}` | no |

### Route Object Definition

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the route. | `string` | — | yes |
| address_prefix | Destination CIDR (e.g. `10.1.0.0/16`, `0.0.0.0/0`) or Azure Service Tag. | `string` | — | yes |
| next_hop_type | The type of Azure hop (`VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance`, or `None`). | `string` | — | yes |
| next_hop_in_ip_address | The IP address packets should be forwarded to. Allowed/required only when `next_hop_type` is `VirtualAppliance`. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Route Table. |
| name | The Name of the Route Table. |
| resource_group_name | The name of the Resource Group in which the Route Table was created. |
| location | The Azure Region of the Route Table. |
| bgp_route_propagation_enabled | Whether BGP route propagation is enabled for the Route Table. |
| subnets | The collection of Subnets associated with this Route Table. |
| routes | The list of routes configured in the Route Table. |
| route_table | The full Azure Route Table resource object. |
| subnet_associations | Map of subnet route table associations created. |

## Usage

```hcl
module "route_table" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/route-table?ref=v0.7.6"

  name                          = "rt-spoke-prod"
  resource_group_name           = "rg-network-prod"
  location                      = "eastus"
  bgp_route_propagation_enabled = false

  routes = [
    {
      name                   = "route-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    },
    {
      name           = "route-to-internet"
      address_prefix = "10.0.0.0/8"
      next_hop_type  = "VnetLocal"
    }
  ]

  subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-spoke-prod/subnets/snet-app"
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
