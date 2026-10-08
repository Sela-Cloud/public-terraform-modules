# Azure Application Gateway Terraform Child Module

Terraform module to provision an [Azure Application Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway).

Azure Application Gateway is a web traffic load balancer (layer 7) that enables you to manage traffic to your web applications. It includes features like SSL termination, cookie-based session affinity, round-robin traffic distribution, URL-based routing, multiple-site hosting, and integrated Web Application Firewall (WAF).

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
| [azurerm_application_gateway.app_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Application Gateway. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Application Gateway. | `string` | n/a | yes |
| location | The Azure region where the Application Gateway should exist. | `string` | n/a | yes |
| sku | The SKU of the Application Gateway (e.g. Standard_v2, WAF_v2). | `object` | `{ name = "Standard_v2", tier = "Standard_v2", capacity = null }` | yes |
| gateway_ip_configurations | One or two gateway_ip_configuration blocks defining the subnet(s). | `list(object)` | n/a | yes |
| frontend_ip_configurations | One or more frontend_ip_configuration blocks. | `list(object)` | n/a | yes |
| frontend_ports | One or more frontend_port blocks. | `list(object)` | n/a | yes |
| backend_address_pools | One or more backend_address_pool blocks. | `list(object)` | n/a | yes |
| backend_http_settings | One or more backend_http_settings blocks. | `list(object)` | n/a | yes |
| http_listeners | One or more http_listener blocks. | `list(object)` | n/a | yes |
| request_routing_rules | One or more request_routing_rule blocks. | `list(object)` | n/a | yes |
| autoscale_configuration | Autoscale configuration for the Application Gateway. | `object` | `{ min_capacity = 1, max_capacity = 10 }` | no |
| probes | One or more probe blocks for custom health checking. | `list(object)` | `[]` | no |
| identity | Managed Service Identity block for Key Vault certificate access. | `object` | `null` | no |
| ssl_certificates | One or more ssl_certificate blocks. | `list(object)` | `[]` | no |
| ssl_policy | Global SSL policy block. | `object` | `null` | no |
| trusted_root_certificates | One or more trusted_root_certificate blocks. | `list(object)` | `[]` | no |
| redirect_configurations | One or more redirect_configuration blocks. | `list(object)` | `[]` | no |
| url_path_maps | One or more url_path_map blocks for path-based routing. | `list(object)` | `[]` | no |
| rewrite_rule_sets | One or more rewrite_rule_set blocks. | `list(object)` | `[]` | no |
| waf_configuration | Web Application Firewall (WAF) configuration block. | `object` | `null` | no |
| zones | Availability Zones in which this Application Gateway should be deployed. | `list(string)` | `null` | no |
| http2_enabled | Is HTTP2 enabled on the application gateway? | `bool` | `true` | no |
| fips_enabled | Is FIPS enabled on the application gateway? | `bool` | `null` | no |
| firewall_policy_id | The ID of the Web Application Firewall Policy. | `string` | `null` | no |
| force_firewall_policy_association | Is the Firewall Policy associated with the Application Gateway forced? | `bool` | `null` | no |
| global | Global configuration for buffering. | `object` | `null` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### Gateway IP Configuration Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the gateway IP configuration. | `string` | n/a | yes |
| subnet_id | The ID of the subnet the Application Gateway should use. | `string` | n/a | yes |

### Frontend IP Configuration Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the frontend IP configuration. | `string` | n/a | yes |
| subnet_id | The ID of the subnet for a private frontend IP. | `string` | `null` | no |
| private_ip_address | Static private IP address. | `string` | `null` | no |
| private_ip_address_allocation | Allocation method (`Static` or `Dynamic`). | `string` | `null` | no |
| public_ip_address_id | The ID of a Public IP Address. | `string` | `null` | no |
| private_link_configuration_name | The name of Private Link configuration. | `string` | `null` | no |

### Frontend Port Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the frontend port. | `string` | n/a | yes |
| port | The port number (e.g. `80`, `443`). | `number` | n/a | yes |

### Backend Address Pool Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the backend address pool. | `string` | n/a | yes |
| fqdns | A list of FQDNs for backend targets. | `list(string)` | `null` | no |
| ip_addresses | A list of IP addresses for backend targets. | `list(string)` | `null` | no |

### Backend HTTP Settings Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the backend HTTP settings. | `string` | n/a | yes |
| port | Port on the backend servers. | `number` | n/a | yes |
| protocol | Protocol (`Http` or `Https`). | `string` | `"Http"` | no |
| cookie_based_affinity | Cookie-based affinity (`Enabled` or `Disabled`). | `string` | `"Disabled"` | no |
| affinity_cookie_name | The cookie name used for session affinity. | `string` | `null` | no |
| path | Path prefix to append to request URI. | `string` | `null` | no |
| request_timeout | Request timeout in seconds. | `number` | `60` | no |
| probe_name | Name of custom health probe to associate. | `string` | `null` | no |
| host_name | Host header to send to backend servers. | `string` | `null` | no |
| pick_host_name_from_backend_address | Whether host name is picked from backend address. | `bool` | `false` | no |
| trusted_root_certificate_names | List of trusted root certificate names. | `list(string)` | `null` | no |
| connection_draining | Connection draining settings. | `object` | `null` | no |

### HTTP Listener Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the HTTP listener. | `string` | n/a | yes |
| frontend_ip_configuration_name | Name of the frontend IP configuration. | `string` | n/a | yes |
| frontend_port_name | Name of the frontend port. | `string` | n/a | yes |
| protocol | Protocol (`Http` or `Https`). | `string` | `"Http"` | no |
| host_name | Host header to listen on. | `string` | `null` | no |
| host_names | List of host header names to listen on. | `list(string)` | `null` | no |
| require_sni | Whether SNI is required for HTTPS. | `bool` | `false` | no |
| ssl_certificate_name | Name of SSL certificate associated with listener. | `string` | `null` | no |
| ssl_profile_name | Name of SSL profile associated with listener. | `string` | `null` | no |
| firewall_policy_id | WAF Policy ID for listener-level WAF. | `string` | `null` | no |
| custom_error_configuration | List of custom error configurations. | `list(object)` | `[]` | no |

### Request Routing Rule Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the request routing rule. | `string` | n/a | yes |
| http_listener_name | Name of the associated HTTP listener. | `string` | n/a | yes |
| rule_type | Rule type (`Basic` or `PathBasedRouting`). | `string` | `"Basic"` | no |
| backend_address_pool_name | Name of backend address pool to route to. | `string` | `null` | no |
| backend_http_settings_name | Name of backend HTTP settings to use. | `string` | `null` | no |
| redirect_configuration_name | Name of redirect configuration to use. | `string` | `null` | no |
| rewrite_rule_set_name | Name of rewrite rule set to associate. | `string` | `null` | no |
| url_path_map_name | Name of URL path map for path-based routing. | `string` | `null` | no |
| priority | Rule evaluation priority (1-20000, required for v2). | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Application Gateway. |
| name | The Name of the Application Gateway. |
| resource_group_name | The Resource Group Name of the Application Gateway. |
| location | The Azure Region of the Application Gateway. |
| frontend_ip_configuration | The frontend IP configurations of the Application Gateway. |
| frontend_port | The frontend ports of the Application Gateway. |
| gateway_ip_configuration | The gateway IP configurations of the Application Gateway. |
| backend_address_pool | The backend address pools of the Application Gateway. |
| backend_http_settings | The backend HTTP settings of the Application Gateway. |
| http_listener | The HTTP listeners of the Application Gateway. |
| request_routing_rule | The request routing rules of the Application Gateway. |
| application_gateway | The full Azure Application Gateway resource object. |

## Usage Examples

### Basic Application Gateway with Autoscale (v2)

```hcl
module "application_gateway" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-gateway?ref=azure-wip"

  name                = "appgw-prod-eastus"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"

  sku = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 5
  }

  gateway_ip_configurations = [
    {
      name      = "appgw-gateway-ip-config"
      subnet_id = "/subscriptions/.../resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-appgw"
    }
  ]

  frontend_ip_configurations = [
    {
      name                 = "appgw-public-frontend-ip"
      public_ip_address_id = "/subscriptions/.../resourceGroups/rg-prod-networking/providers/Microsoft.Network/publicIPAddresses/pip-appgw-prod"
    }
  ]

  frontend_ports = [
    {
      name = "port-80"
      port = 80
    }
  ]

  backend_address_pools = [
    {
      name         = "backend-pool-web"
      ip_addresses = ["10.0.1.10", "10.0.1.11"]
    }
  ]

  backend_http_settings = [
    {
      name                  = "http-settings-80"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 30
    }
  ]

  http_listeners = [
    {
      name                           = "http-listener-80"
      frontend_ip_configuration_name = "appgw-public-frontend-ip"
      frontend_port_name             = "port-80"
      protocol                       = "Http"
    }
  ]

  request_routing_rules = [
    {
      name                       = "rule-basic-web"
      rule_type                  = "Basic"
      http_listener_name         = "http-listener-80"
      backend_address_pool_name  = "backend-pool-web"
      backend_http_settings_name = "http-settings-80"
      priority                   = 100
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
