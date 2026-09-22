# Azure VPN Gateway Terraform Child Module

Terraform module to provision an [Azure VPN Gateway](https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/vpn_gateway).

An Azure VPN Gateway in a Virtual WAN Virtual Hub enables site-to-site VPN connectivity between branch offices, on-premises networks, and the Azure Virtual WAN hub with dynamic BGP routing support and scalable throughput units.

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
| [azurerm_vpn_gateway.gateway](https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/vpn_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name which should be used for this VPN Gateway. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which this VPN Gateway should be created. | `string` | n/a | yes |
| location | The Azure location where this VPN Gateway should be created. | `string` | n/a | yes |
| virtual_hub_id | The ID of the Virtual Hub in which the VPN Gateway should be created. | `string` | n/a | yes |
| scale_unit | The Scale Unit for this VPN Gateway (1-100). | `number` | `1` | no |
| bgp_settings | Optional BGP settings block for dynamic routing configuration. | `object` | `null` | no |
| tags | A mapping of tags to assign to the VPN Gateway. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### BGP Settings Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| asn | The Autonomous System Number for the BGP speaker. | `number` | `65515` | no |
| peer_weight | The weight added to routes learned from the BGP peer. | `number` | `0` | no |
| instance_0_custom_ips | List of custom BGP peering APIPA IP addresses for Gateway Instance 0. | `list(string)` | `[]` | no |
| instance_1_custom_ips | List of custom BGP peering APIPA IP addresses for Gateway Instance 1. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the VPN Gateway. |
| name | The Name of the VPN Gateway. |
| bgp_settings | The BGP settings block and computed BGP peering addresses. |
| vpn_gateway | The full Azure VPN Gateway resource object. |

## Usage Examples

### Standard Virtual WAN VPN Gateway

```hcl
module "vpn_gateway" {
  source = "../../modules/azure/vpn-gateway"

  name                = "vwan-vpn-gw-prod"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"
  virtual_hub_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualHubs/vwan-hub-prod"
  scale_unit          = 2

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### VPN Gateway with Custom BGP APIPA Peering Addresses

```hcl
module "vpn_gateway_bgp" {
  source = "../../modules/azure/vpn-gateway"

  name                = "vwan-vpn-gw-bgp"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"
  virtual_hub_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualHubs/vwan-hub-prod"
  scale_unit          = 1

  bgp_settings = {
    asn                   = 65515
    peer_weight           = 0
    instance_0_custom_ips = ["169.254.21.1"]
    instance_1_custom_ips = ["169.254.21.5"]
  }

  tags = {
    Environment = "production"
  }
}
```
