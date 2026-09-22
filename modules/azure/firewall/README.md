# Azure Firewall Terraform Child Module

Terraform module to provision an [Azure Firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall).

Azure Firewall is a cloud-native, intelligent network firewall security service providing threat protection for cloud workloads running in Azure. It supports both Virtual Network (`AZFW_VNet`) deployments and Virtual WAN Secured Virtual Hub (`AZFW_Hub`) deployments with built-in high availability and unrestricted cloud scalability.

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
| [azurerm_firewall.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Azure Firewall. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which the Azure Firewall should exist. | `string` | n/a | yes |
| location | Supported Azure location where the resource exists. | `string` | n/a | yes |
| sku_name | SKU name of the Firewall (`AZFW_VNet` or `AZFW_Hub`). | `string` | n/a | yes |
| sku_tier | SKU tier of the Firewall (`Basic`, `Standard`, `Premium`). | `string` | n/a | yes |
| ip_configuration | A list of IP configuration blocks. Used when `sku_name` is `AZFW_VNet`. | `list(object)` | `[]` | no |
| management_ip_configuration | Management IP configuration block for forced tunneling or Basic SKU. | `object` | `null` | no |
| virtual_hub | Virtual Hub block used when `sku_name` is `AZFW_Hub`. | `object` | `null` | no |
| firewall_policy_id | The ID of the Firewall Policy associated with this Firewall. | `string` | `null` | no |
| dns_servers | A list of DNS server IP addresses used by the Azure Firewall. | `list(string)` | `[]` | no |
| dns_proxy_enabled | Whether DNS proxy is enabled on the Azure Firewall. | `bool` | `false` | no |
| threat_intel_mode | Threat intelligence mode (`Off`, `Alert`, `Deny`). | `string` | `"Alert"` | no |
| zones | A list of Availability Zones to deploy the firewall into. | `list(string)` | `[]` | no |
| private_ip_ranges | A list of SNAT private CIDR IP ranges or `['IANAPrivateRanges']`. | `list(string)` | `null` | no |
| tags | A mapping of tags to assign to the Azure Firewall. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### IP Configuration Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the IP configuration. | `string` | n/a | yes |
| subnet_id | Subnet ID (must be `AzureFirewallSubnet`). Required for the primary IP configuration. | `string` | `null` | no |
| public_ip_address_id | Public IP address resource ID. | `string` | `null` | no |

### Management IP Configuration Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the management IP configuration. | `string` | n/a | yes |
| subnet_id | Subnet ID (must be `AzureFirewallManagementSubnet`). | `string` | n/a | yes |
| public_ip_address_id | Public IP address resource ID. | `string` | n/a | yes |

### Virtual Hub Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| virtual_hub_id | The ID of the Virtual Hub where the firewall is deployed. | `string` | n/a | yes |
| public_ip_count | The number of public IPs assigned to the firewall in the hub. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Azure Firewall. |
| name | The Name of the Azure Firewall. |
| ip_configuration | The IP configuration block of the Azure Firewall with `private_ip_address`. |
| virtual_hub | The virtual hub block of the Azure Firewall if configured. |
| firewall | The full Azure Firewall resource object. |

## Usage Examples

### Standard VNet-based Azure Firewall

```hcl
module "firewall" {
  source = "../../modules/azure/firewall"

  name                = "afw-hub-prod"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  zones               = ["1", "2", "3"]
  threat_intel_mode   = "Alert"
  dns_proxy_enabled   = true

  ip_configuration = [
    {
      name                 = "primary"
      subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/AzureFirewallSubnet"
      public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/publicIPAddresses/pip-afw-prod"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Secured Virtual WAN Hub Azure Firewall

```hcl
module "hub_firewall" {
  source = "../../modules/azure/firewall"

  name                = "afw-vwan-hub"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"
  sku_name            = "AZFW_Hub"
  sku_tier            = "Premium"
  firewall_policy_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/firewallPolicies/afwp-prod"

  virtual_hub = {
    virtual_hub_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualHubs/vhub-eastus"
    public_ip_count = 1
  }

  tags = {
    Environment = "production"
  }
}
```
