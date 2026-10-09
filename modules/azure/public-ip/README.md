# Azure Public IP Terraform Child Module

Terraform module to provision an [Azure Public IP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip).

This module manages the Azure Public IP resource (`azurerm_public_ip`), providing public IPv4 and IPv6 connectivity for Azure resources like Load Balancers, Virtual Machines, Application Gateways, NAT Gateways, and Bastion Hosts.

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
| [azurerm_public_ip.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Public IP (1-80 characters). | `string` | — | yes |
| resource_group_name | The name of the Resource Group in which to create the Public IP. | `string` | — | yes |
| location | The Azure Region where the Public IP should exist. | `string` | — | yes |
| allocation_method | Allocation method (`Static` or `Dynamic`). | `string` | `"Static"` | no |
| sku | The SKU of the Public IP (`Basic` or `Standard`). | `string` | `"Standard"` | no |
| sku_tier | The SKU Tier (`Regional` or `Global`). | `string` | `"Regional"` | no |
| ip_version | IP Version (`IPv4` or `IPv6`). | `string` | `"IPv4"` | no |
| idle_timeout_in_minutes | Timeout for TCP idle connection in minutes (4-30). | `number` | `4` | no |
| domain_name_label | Label for Domain Name used for Azure DNS FQDN. | `string` | `null` | no |
| reverse_fqdn | Fully qualified domain name resolving to this public IP for PTR record. | `string` | `null` | no |
| zones | List of availability zones to allocate the Public IP in. | `list(string)` | `[]` | no |
| ddos_protection_mode | DDoS protection mode (`Disabled`, `Enabled`, `VirtualNetworkInherited`). | `string` | `"VirtualNetworkInherited"` | no |
| ddos_protection_plan_id | Resource ID of the DDoS protection plan. | `string` | `null` | no |
| edge_zone | Edge Zone within Azure Region where Public IP should exist. | `string` | `null` | no |
| public_ip_prefix_id | Public IP Prefix resource ID to allocate from. | `string` | `null` | no |
| ip_tags | A mapping of IP tags to assign to the public IP. | `map(string)` | `{}` | no |
| tags | A mapping of tags which should be assigned to the Public IP. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Public IP. |
| name | The Name of the Public IP. |
| resource_group_name | The Resource Group of the Public IP. |
| location | The Azure Region of the Public IP. |
| ip_address | The allocated IP address value. |
| fqdn | The Fully Qualified Domain Name of the DNS record. |
| sku | The SKU of the Public IP. |
| sku_tier | The SKU Tier of the Public IP. |
| allocation_method | The allocation method of the Public IP. |
| zones | Availability Zones associated with the Public IP. |
| tags | The tags assigned to the Public IP. |
| public_ip | The full Azure Public IP resource object. |

## Usage

```hcl
module "public_ip" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/public-ip?ref=azure-public-ip"

  name                = "pip-workload-prod-eastus-01"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
  zones               = ["1", "2", "3"]

  domain_name_label = "myworkload-prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
