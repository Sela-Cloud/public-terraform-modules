# Azure Virtual Network Peering Terraform Child Module

Terraform module to provision an [Azure Virtual Network Peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering).

Virtual network peering enables you to seamlessly connect two Azure virtual networks. The virtual networks appear as one for connectivity purposes. Traffic between virtual machines in peered virtual networks uses the Microsoft backbone infrastructure.

> **Note**: Virtual network peering is **directional**. To establish bidirectional connectivity between two virtual networks, you must create two peering resources (one from VNet A to VNet B, and one from VNet B to VNet A).

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
| [azurerm_virtual_network_peering.peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Virtual Network Peering. | `string` | `"peer-default"` | no |
| resource_group_name | The name of the Resource Group in which the Virtual Network Peering should exist. | `string` | `"rg-default"` | no |
| virtual_network_name | The name of the local Virtual Network. | `string` | `"vnet-default"` | no |
| remote_virtual_network_id | The full Azure resource ID of the remote Virtual Network to be peered. | `string` | — | yes |
| allow_virtual_network_access | Controls whether VMs in the local virtual network can access VMs in the remote virtual network. | `bool` | `true` | no |
| allow_forwarded_traffic | Controls whether forwarded traffic from VMs in the remote virtual network will be allowed. | `bool` | `false` | no |
| allow_gateway_transit | Controls whether gateway links can be used in the remote virtual network's link to the local virtual network. | `bool` | `false` | no |
| use_remote_gateways | Controls if remote gateways can be used on the local virtual network. | `bool` | `false` | no |
| peer_complete_virtual_networks_enabled | Specifies whether the complete Virtual Network address space is peered. | `bool` | `true` | no |
| local_subnet_names | A list of local Subnet names that are Subnet peered with the remote Virtual Network. | `list(string)` | `null` | no |
| remote_subnet_names | A list of remote Subnet names from the remote Virtual Network that are Subnet peered. | `list(string)` | `null` | no |
| only_ipv6_peering_enabled | Specifies whether only IPv6 address space is peered for Subnet peering. | `bool` | `false` | no |
| triggers | A mapping of key-value pairs that forces recreation when external dependencies change. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Virtual Network Peering. |
| name | The Name of the Virtual Network Peering. |
| resource_group_name | The Resource Group Name in which the Virtual Network Peering was created. |
| virtual_network_name | The Name of the local Virtual Network. |
| remote_virtual_network_id | The Resource ID of the remote Virtual Network. |
| virtual_network_peering | The full Azure Virtual Network Peering resource object. |

## Usage

### Bidirectional Peering Example (Hub & Spoke)

```hcl
# Peering from Hub VNet to Spoke VNet
module "peering_hub_to_spoke" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-network-peering?ref=v0.7.6"

  name                      = "peer-hub-to-spoke"
  resource_group_name       = "rg-hub-prod"
  virtual_network_name      = "vnet-hub-prod"
  remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke-prod/providers/Microsoft.Network/virtualNetworks/vnet-spoke-prod"

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

# Peering from Spoke VNet to Hub VNet
module "peering_spoke_to_hub" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-network-peering?ref=v0.7.6"

  name                      = "peer-spoke-to-hub"
  resource_group_name       = "rg-spoke-prod"
  virtual_network_name      = "vnet-spoke-prod"
  remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod"

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}
```
