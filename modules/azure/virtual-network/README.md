# Azure Virtual Network Terraform Child Module

Terraform module to provision an [Azure Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network).

This module manages the core Azure Virtual Network (VNet) resource. In line with best practices, subnets and network security groups (NSGs) are managed as standalone resources and associations rather than inline.

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
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Virtual Network. Changing this forces a new resource to be created. | `string` | `"vnet-default"` | no |
| resource_group_name | The name of the resource group in which to create the Virtual Network. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Virtual Network should exist. | `string` | `"eastus"` | no |
| address_space | The address space that is used by the Virtual Network. | `list(string)` | `["10.0.0.0/16"]` | no |
| dns_servers | List of IP addresses of DNS servers. If not specified, Azure default DNS is used. | `list(string)` | `[]` | no |
| bgp_community | The BGP community attribute in format `<as-number>:<community-value>`. | `string` | `null` | no |
| flow_timeout_in_minutes | Connection tracking flow timeout in minutes (4 to 30). | `number` | `null` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region. | `string` | `null` | no |
| private_endpoint_vnet_policies | Private Endpoint VNet Policies (`Disabled` or `Basic`). | `string` | `"Disabled"` | no |
| ddos_protection_plan | DDoS Protection Plan configuration (`id` and optional `enable`). | `object` | `null` | no |
| encryption | Virtual Network encryption configuration (`enforcement`). | `object` | `null` | no |
| tags | A mapping of tags which should be assigned to the Virtual Network. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Virtual Network. |
| name | The Name of the Virtual Network. |
| resource_group_name | The name of the Resource Group in which the Virtual Network was created. |
| location | The Azure Region of the Virtual Network. |
| address_space | The list of address spaces partitioned for the Virtual Network. |
| dns_servers | The list of DNS servers configured for the Virtual Network. |
| guid | The GUID of the Virtual Network. |
| virtual_network | The full Azure Virtual Network resource object. |

## Usage

```hcl
module "virtual_network" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-network?ref=v0.7.6"

  name                = "vnet-workload-prod"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  dns_servers = [
    "10.0.0.4",
    "10.0.0.5"
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
