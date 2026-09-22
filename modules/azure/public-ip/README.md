# Azure Public IP Terraform Child Module

Terraform module to provision an [Azure Public IP Address](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip).

This module manages the Azure Public IP resource (`azurerm_public_ip`), which provides inbound and outbound internet connectivity for Azure resources such as Virtual Machines, Load Balancers, Application Gateways, and NAT Gateways.

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
| name | The name of the Public IP. Changing this forces a new resource to be created. | `string` | `"pip-default"` | no |
| resource_group_name | The name of the Resource Group in which to create the Public IP. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Public IP should exist. | `string` | `"eastus"` | no |
| allocation_method | Defines the allocation method for this IP address (`Static` or `Dynamic`). | `string` | `"Static"` | no |
| sku | The SKU of the Public IP (`Basic` or `Standard`). | `string` | `"Standard"` | no |
| sku_tier | The SKU Tier for the Public IP (`Regional` or `Global`). | `string` | `"Regional"` | no |
| ip_version | The IP Version to use (`IPv4` or `IPv6`). | `string` | `"IPv4"` | no |
| idle_timeout_in_minutes | Specifies the timeout for the TCP idle connection (4-30 minutes). | `number` | `4` | no |
| domain_name_label | Label for the Domain Name used to create the FQDN. | `string` | `null` | no |
| reverse_fqdn | A fully qualified domain name that resolves to this public IP address. | `string` | `null` | no |
| zones | A collection containing the availability zone(s) to allocate the Public IP in. | `list(string)` | `[]` | no |
| ddos_protection_mode | The DDoS protection mode (`Disabled`, `Enabled`, or `VirtualNetworkInherited`). | `string` | `"VirtualNetworkInherited"` | no |
| ddos_protection_plan_id | The ID of DDoS protection plan associated with the public IP. | `string` | `null` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region. | `string` | `null` | no |
| public_ip_prefix_id | Associated Public IP Prefix resource ID. | `string` | `null` | no |
| ip_tags | A mapping of IP tags to assign to the public IP. | `map(string)` | `{}` | no |
| tags | A mapping of tags which should be assigned to the Public IP. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Public IP. |
| name | The Name of the Public IP. |
| resource_group_name | The name of the Resource Group in which the Public IP was created. |
| location | The Azure Region of the Public IP. |
| ip_address | The IP address value that was allocated. |
| fqdn | The Fully Qualified Domain Name of the DNS record associated with the Public IP. |
| sku | The SKU of the Public IP. |
| sku_tier | The SKU Tier of the Public IP. |
| allocation_method | The allocation method of the Public IP. |
| zones | The Availability Zones associated with the Public IP. |
| tags | The tags assigned to the Public IP. |
| public_ip | The full Azure Public IP resource object. |

## Usage

```hcl
module "public_ip" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/public-ip?ref=v0.7.6"

  name                = "pip-workload-prod"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
