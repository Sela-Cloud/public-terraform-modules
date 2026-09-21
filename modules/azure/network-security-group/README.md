# Azure Network Security Group Terraform Child Module

Terraform module to provision an [Azure Network Security Group (NSG)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group).

This module manages the core Azure Network Security Group resource with inline security rules and resource tagging.

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
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Network Security Group. Changing this forces a new resource to be created. | `string` | `"nsg-default"` | no |
| resource_group_name | The name of the resource group in which to create the Network Security Group. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Network Security Group should exist. | `string` | `"eastus"` | no |
| security_rules | List of security rules representing inline rules to be created with the Network Security Group. | `list(object)` | `[]` | no |
| tags | A mapping of tags which should be assigned to the Network Security Group. | `map(string)` | `{}` | no |

### Security Rule Object Definition

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the security rule. | `string` | — | yes |
| description | Optional description for this rule. | `string` | `null` | no |
| protocol | Network protocol (`Tcp`, `Udp`, `Icmp`, `Esp`, `Ah`, or `*`). | `string` | `"*"` | no |
| source_port_range | Source Port or Range (`0`-`65535` or `*`). | `string` | `"*"` | no |
| source_port_ranges | List of source ports or ranges. | `list(string)` | `null` | no |
| destination_port_range | Destination Port or Range (`0`-`65535` or `*`). | `string` | `"*"` | no |
| destination_port_ranges | List of destination ports or ranges. | `list(string)` | `null` | no |
| source_address_prefix | CIDR, IP range, or service tag (`VirtualNetwork`, `Internet`, etc.) or `*`. | `string` | `"*"` | no |
| source_address_prefixes | List of source address prefixes. | `list(string)` | `null` | no |
| source_application_security_group_ids | List of source Application Security Group IDs. | `list(string)` | `null` | no |
| destination_address_prefix | CIDR, IP range, or service tag or `*`. | `string` | `"*"` | no |
| destination_address_prefixes | List of destination address prefixes. | `list(string)` | `null` | no |
| destination_application_security_group_ids | List of destination Application Security Group IDs. | `list(string)` | `null` | no |
| access | Whether network traffic is allowed or denied (`Allow` or `Deny`). | `string` | `"Allow"` | no |
| priority | Rule priority between `100` and `4096`. | `number` | `100` | no |
| direction | Direction of traffic evaluation (`Inbound` or `Outbound`). | `string` | `"Inbound"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Network Security Group. |
| name | The Name of the Network Security Group. |
| resource_group_name | The name of the Resource Group in which the Network Security Group was created. |
| location | The Azure Region of the Network Security Group. |
| security_rules | The list of security rules configured in the Network Security Group. |
| network_security_group | The full Azure Network Security Group resource object. |

## Usage

```hcl
module "network_security_group" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-security-group?ref=v0.7.6"

  name                = "nsg-web-prod"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"

  security_rules = [
    {
      name                   = "allow-http"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "80"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    },
    {
      name                   = "allow-https"
      priority               = 110
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "443"
      source_address_prefix  = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
