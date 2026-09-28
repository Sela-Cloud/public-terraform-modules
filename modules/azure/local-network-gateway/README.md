# Azure Local Network Gateway Terraform Child Module

Terraform module to provision an [Azure Local Network Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway).

An Azure Local Network Gateway represents an on-premises VPN device/router in Azure. It is used in conjunction with a Virtual Network Gateway to establish Site-to-Site (IPsec/IKE) VPN connections between Azure Virtual Networks and on-premises networks, supporting both static routing and dynamic BGP routing.

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
| [azurerm_local_network_gateway.gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Local Network Gateway. Changing this forces a new resource to be created. | `string` | `"lng-default"` | yes |
| resource_group_name | The name of the Resource Group in which to create the Local Network Gateway. | `string` | `"rg-default"` | yes |
| location | The Azure Region where the Local Network Gateway should exist. | `string` | n/a | yes |
| gateway_address | The gateway IP address in IPv4 format to connect with. Specify either `gateway_address` or `gateway_fqdn`. | `string` | `null` | no |
| gateway_fqdn | The gateway FQDN to connect with. Specify either `gateway_address` or `gateway_fqdn`. | `string` | `null` | no |
| address_space | The list of string CIDRs representing the address spaces the gateway exposes. | `list(string)` | `[]` | no |
| bgp_settings | Optional BGP settings block for dynamic routing configuration. | `object` | `null` | no |
| tags | A mapping of tags which should be assigned to the Local Network Gateway. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### BGP Settings Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| asn | The Autonomous System Number for the on-premises BGP speaker. | `number` | `65510` | no |
| bgp_peering_address | The IP address of the on-premises BGP speaker. | `string` | `null` | no |
| peer_weight | The weight added to routes learned from the BGP peer. | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Local Network Gateway. |
| name | The Name of the Local Network Gateway. |
| bgp_settings | The BGP settings block of the Local Network Gateway, if configured. |
| local_network_gateway | The full Azure Local Network Gateway resource object. |

## Usage Examples

### Standard IP-Based Site-to-Site Local Network Gateway

```hcl
module "local_network_gateway" {
  source = "../../modules/azure/local-network-gateway"

  name                = "lng-onprem-datacenter"
  resource_group_name = "rg-networking-prod"
  location            = "eastus"
  gateway_address     = "198.51.100.1"
  address_space       = ["10.1.0.0/16", "10.2.0.0/16"]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### FQDN-Based Local Network Gateway

```hcl
module "local_network_gateway_fqdn" {
  source = "../../modules/azure/local-network-gateway"

  name                = "lng-branch-office"
  resource_group_name = "rg-networking-prod"
  location            = "eastus"
  gateway_fqdn        = "vpn.branch.example.com"
  address_space       = ["192.168.1.0/24"]

  tags = {
    Environment = "production"
  }
}
```

### BGP-Enabled Local Network Gateway

```hcl
module "local_network_gateway_bgp" {
  source = "../../modules/azure/local-network-gateway"

  name                = "lng-onprem-bgp"
  resource_group_name = "rg-networking-prod"
  location            = "eastus"
  gateway_address     = "198.51.100.1"
  address_space       = ["10.0.0.0/8"]

  bgp_settings = {
    asn                 = 65000
    bgp_peering_address = "10.0.0.1"
    peer_weight         = 100
  }

  tags = {
    Environment = "production"
  }
}
```
