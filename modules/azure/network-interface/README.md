# Azure Network Interface (NIC) Terraform Child Module

Terraform module to provision an [Azure Network Interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface).

A network interface enables an Azure Virtual Machine to communicate with internet, Azure, and on-premises resources. This module supports multiple IP configurations, accelerated networking, IP forwarding, internal DNS name labels, custom DNS servers, and optional Network Security Group (NSG) association.

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
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Network Interface. | `string` | — | yes |
| resource_group_name | The name of the Resource Group in which to create the Network Interface. | `string` | — | yes |
| location | The Azure Region where the Network Interface should exist. | `string` | — | yes |
| ip_configurations | List of IP configuration blocks for this Network Interface. | `list(object)` | — | yes |
| dns_servers | List of IP addresses of DNS servers assigned to this NIC. | `list(string)` | `[]` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region where this NIC should exist. | `string` | `null` | no |
| enable_ip_forwarding | Enable IP Forwarding on this Network Interface. | `bool` | `false` | no |
| enable_accelerated_networking | Enable Azure Accelerated Networking on this Network Interface. | `bool` | `false` | no |
| internal_dns_name_label | Relative DNS name for internal VM communication. | `string` | `null` | no |
| network_security_group_id | ID of the Network Security Group to associate with this NIC. | `string` | `null` | no |
| auxiliary_mode | Specifies auxiliary mode (`AcceleratedConnections`, `Floating`, or `None`). | `string` | `null` | no |
| auxiliary_sku | Specifies auxiliary sku (`A8`, `A4`, or `None`). | `string` | `null` | no |
| tags | A mapping of tags which should be assigned to the Network Interface. | `map(string)` | `{}` | no |

### IP Configuration Object Definition

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | Name of the IP configuration. | `string` | — | yes |
| subnet_id | ID of the Subnet where this NIC should be located. | `string` | `null` | no |
| private_ip_address_allocation | Allocation method (`Dynamic` or `Static`). | `string` | `"Dynamic"` | no |
| private_ip_address | Static Private IP address (required if allocation is `Static`). | `string` | `null` | no |
| private_ip_address_version | IP address version (`IPv4` or `IPv6`). | `string` | `"IPv4"` | no |
| public_ip_address_id | ID of an associated Public IP address resource. | `string` | `null` | no |
| primary | Whether this is the primary IP configuration. | `bool` | `true` | no |
| gateway_load_balancer_frontend_ip_configuration_id | Frontend IP configuration ID of a Gateway Load Balancer. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Network Interface. |
| name | The Name of the Network Interface. |
| resource_group_name | The Resource Group Name in which the Network Interface was created. |
| location | The Azure Region of the Network Interface. |
| applied_dns_servers | List of applied DNS servers. |
| internal_domain_name_suffix | Internal domain name suffix. |
| mac_address | The Media Access Control (MAC) address of the Network Interface. |
| private_ip_address | The first private IP address of the Network Interface. |
| private_ip_addresses | The list of all private IP addresses of the Network Interface. |
| virtual_machine_id | The ID of the Virtual Machine with which this NIC is associated. |
| network_interface | The full Azure Network Interface resource object. |
| network_security_group_association | The Network Security Group association object (if created). |

## Usage Examples

### Dynamic Private IP Configuration

```hcl
module "network_interface" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-interface?ref=v0.7.6"

  name                = "nic-web-prod"
  resource_group_name = "rg-network-prod"
  location            = "eastus"

  enable_accelerated_networking = true

  ip_configurations = [
    {
      name                          = "internal"
      subnet_id                     = "/subscriptions/.../virtualNetworks/vnet-prod/subnets/snet-web"
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
  ]

  network_security_group_id = "/subscriptions/.../networkSecurityGroups/nsg-web-prod"

  tags = {
    Environment = "production"
    Tier        = "frontend"
  }
}
```

### Static IP Configuration with Public IP

```hcl
module "network_interface" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-interface?ref=v0.7.6"

  name                = "nic-fw-prod"
  resource_group_name = "rg-network-prod"
  location            = "eastus"

  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configurations = [
    {
      name                          = "ipconfig1"
      subnet_id                     = "/subscriptions/.../virtualNetworks/vnet-prod/subnets/snet-dmz"
      private_ip_address_allocation = "Static"
      private_ip_address            = "10.0.1.4"
      public_ip_address_id          = "/subscriptions/.../publicIPAddresses/pip-fw-prod"
      primary                       = true
    }
  ]

  tags = {
    Environment = "production"
    Role        = "firewall"
  }
}
```
