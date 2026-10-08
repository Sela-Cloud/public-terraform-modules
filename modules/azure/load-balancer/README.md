# Azure Load Balancer Terraform Child Module

Terraform module to provision an [Azure Load Balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) alongside optional Backend Address Pools, Health Probes, Load Balancing Rules, and Inbound NAT Rules.

This module manages the Azure Load Balancer resource (`azurerm_lb`), supporting both Public (Internet-facing) and Internal (Private VNet) architectures, Regional and Global tiers, and Standard/Gateway SKUs.

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
| [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.backend_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_nat_rule.nat_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Azure Load Balancer. | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which to create the Load Balancer. | `string` | n/a | yes |
| location | The Azure Region where the Load Balancer should exist. | `string` | n/a | yes |
| frontend_ip_configurations | List of frontend IP configurations (at least 1 required). | `list(object)` | n/a | yes |
| sku | Sizing SKU of the Load Balancer (`Standard`, `Basic`, `Gateway`). | `string` | `"Standard"` | no |
| sku_tier | Sizing tier (`Regional` or `Global`). | `string` | `"Regional"` | no |
| type | Classification: `Public` (Internet-facing) or `Internal` (Private VNet). | `string` | `"Public"` | no |
| edge_zone | The Edge Zone within the Azure Region where this Load Balancer should exist. | `string` | `null` | no |
| tags | A mapping of tags to assign to the Load Balancer. | `map(string)` | `{}` | no |
| backend_pools | List of backend address pools to create for the Load Balancer. | `list(object)` | `[]` | no |
| health_probes | List of health probes to monitor backend targets. | `list(object)` | `[]` | no |
| load_balancing_rules | List of load balancing distribution rules. | `list(object)` | `[]` | no |
| inbound_nat_rules | List of inbound NAT rules for direct port forwarding. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Load Balancer. |
| name | The name of the Load Balancer. |
| resource_group_name | The name of the Resource Group in which the Load Balancer was created. |
| location | The Azure Region of the Load Balancer. |
| sku | The SKU of the Load Balancer. |
| sku_tier | The SKU tier of the Load Balancer. |
| frontend_ip_configurations | The frontend IP configuration blocks created on the Load Balancer. |
| backend_address_pools | Map of created backend address pools. |
| backend_address_pool_ids | Map of backend address pool names to their Azure resource IDs. |
| health_probes | Map of created health probes. |
| health_probe_ids | Map of health probe names to their Azure resource IDs. |
| load_balancing_rules | Map of created load balancing rules. |
| load_balancing_rule_ids | Map of load balancing rule names to their Azure resource IDs. |
| inbound_nat_rules | Map of created inbound NAT rules. |
| inbound_nat_rule_ids | Map of inbound NAT rule names to their Azure resource IDs. |
| tags | The tags assigned to the Load Balancer. |
| lb | The full Azure Load Balancer resource object. |

## Usage Examples

### Example 1: Standard Public Load Balancer with Backend Pool, Health Probe, and LB Rule

```hcl
module "public_lb" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/load-balancer?ref=v0.7.6"

  name                = "lb-web-prod"
  resource_group_name = "rg-networking-prod"
  location            = "eastus"
  sku                 = "Standard"
  sku_tier            = "Regional"
  type                = "Public"

  frontend_ip_configurations = [
    {
      name                 = "LoadBalancerFrontEnd"
      public_ip_address_id = "/subscriptions/.../resourceGroups/rg-networking-prod/providers/Microsoft.Network/publicIPAddresses/pip-lb-web"
      zones                = ["1", "2", "3"]
    }
  ]

  backend_pools = [
    {
      name = "bepool-web-servers"
    }
  ]

  health_probes = [
    {
      name                = "hp-http-80"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  ]

  load_balancing_rules = [
    {
      name                           = "lbr-http-80"
      frontend_ip_configuration_name = "LoadBalancerFrontEnd"
      frontend_port                  = 80
      backend_port                   = 80
      protocol                       = "Tcp"
      backend_address_pool_name      = "bepool-web-servers"
      probe_name                     = "hp-http-80"
      idle_timeout_in_minutes        = 4
    }
  ]

  tags = {
    Environment = "production"
    Workload    = "web-tier"
  }
}
```

### Example 2: Internal Load Balancer in a Subnet with Inbound NAT Rules

```hcl
module "internal_lb" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/load-balancer?ref=v0.7.6"

  name                = "lb-app-internal-prod"
  resource_group_name = "rg-networking-prod"
  location            = "eastus"
  sku                 = "Standard"
  type                = "Internal"

  frontend_ip_configurations = [
    {
      name                          = "InternalFrontEnd"
      subnet_id                     = "/subscriptions/.../resourceGroups/rg-networking-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-app"
      private_ip_address            = "10.0.2.100"
      private_ip_address_allocation = "Static"
    }
  ]

  backend_pools = [
    {
      name = "bepool-app-servers"
    }
  ]

  health_probes = [
    {
      name     = "hp-tcp-8080"
      protocol = "Tcp"
      port     = 8080
    }
  ]

  load_balancing_rules = [
    {
      name                           = "lbr-tcp-8080"
      frontend_ip_configuration_name = "InternalFrontEnd"
      frontend_port                  = 8080
      backend_port                   = 8080
      protocol                       = "Tcp"
      backend_address_pool_name      = "bepool-app-servers"
      probe_name                     = "hp-tcp-8080"
    }
  ]

  inbound_nat_rules = [
    {
      name                           = "nat-ssh-vm1"
      frontend_ip_configuration_name = "InternalFrontEnd"
      frontend_port                  = 2221
      backend_port                   = 22
      protocol                       = "Tcp"
    }
  ]

  tags = {
    Environment = "production"
    Workload    = "app-tier"
  }
}
```
