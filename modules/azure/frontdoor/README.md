# Azure Front Door (Classic) Terraform Child Module

Terraform module to provision an [Azure Front Door (Classic)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor).

Azure Front Door provides a scalable and secure entry point for fast delivery of global web applications, combining global traffic routing (layer 7 load balancing), SSL offloading, dynamic acceleration, and path-based routing.

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
| [azurerm_frontdoor.frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Front Door service. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | Specifies the name of the Resource Group in which the Front Door service should exist. | `string` | n/a | yes |
| frontend_endpoints | A list of frontend_endpoint blocks configuring the hostnames used to access the Front Door. | `list(object)` | n/a | yes |
| backend_pools | A list of backend_pool blocks configuring the backends that receive traffic from the Front Door. | `list(object)` | n/a | yes |
| routing_rules | A list of routing_rule blocks connecting frontend endpoints to backend pools or redirecting traffic. | `list(object)` | n/a | yes |
| friendly_name | A friendly name for the Front Door service. | `string` | `null` | no |
| load_balancer_enabled | Should the Front Door Load Balancer be enabled? | `bool` | `true` | no |
| backend_pool_load_balancing | A list of backend_pool_load_balancing blocks. | `list(object)` | `[...]` | no |
| backend_pool_health_probes | A list of backend_pool_health_probe blocks. | `list(object)` | `[...]` | no |
| tags | A mapping of tags to assign to the Front Door resource. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### Frontend Endpoint Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the frontend endpoint. | `string` | n/a | yes |
| host_name | The host name of the frontend endpoint (e.g. `example-frontdoor.azurefd.net` or custom domain). | `string` | n/a | yes |
| session_affinity_enabled | Whether session affinity is enabled on this endpoint. | `bool` | `false` | no |
| session_affinity_ttl_seconds | Session affinity TTL in seconds. | `number` | `0` | no |
| web_application_firewall_policy_link_id | WAF policy ID to associate with this endpoint. | `string` | `null` | no |

### Backend Pool Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the backend pool. | `string` | n/a | yes |
| load_balancing_name | The name of the `backend_pool_load_balancing` settings to use. | `string` | n/a | yes |
| health_probe_name | The name of the `backend_pool_health_probe` settings to use. | `string` | n/a | yes |
| backends | A list of backend targets within this backend pool. | `list(object)` | n/a | yes |

#### Backend Target Attributes

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| address | The address of the backend (IPv4 or FQDN). | `string` | n/a | yes |
| host_header | The value to use as the host header sent to the backend. | `string` | n/a | yes |
| enabled | Location to enable or disable traffic to this backend. | `bool` | `true` | no |
| http_port | HTTP TCP port used to access backend. | `number` | `80` | no |
| https_port | HTTPS TCP port used to access backend. | `number` | `443` | no |
| priority | Priority to use for load balancing. | `number` | `1` | no |
| weight | Weight to use for load balancing. | `number` | `50` | no |

### Routing Rule Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the routing rule. | `string` | n/a | yes |
| frontend_endpoints | The names of the frontend endpoints to associate with this rule. | `list(string)` | n/a | yes |
| accepted_protocols | Protocol schemes to accept (`Http`, `Https`). | `list(string)` | `["Http", "Https"]` | no |
| patterns_to_match | Route matching path patterns (e.g. `["/*"]`). | `list(string)` | `["/*"]` | no |
| forwarding_configuration | Forwarding configuration block to route to a backend pool. | `object` | `null` | no |
| redirect_configuration | Redirection configuration block. | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Front Door. |
| name | The Name of the Front Door. |
| cname | The host that each frontendEndpoint must CNAME to. |
| header_frontdoor_id | The unique ID of the Front Door sent as the X-Azure-FDID header. |
| frontend_endpoints | The frontend endpoints mapping of the Front Door. |
| frontdoor | The full Azure Front Door resource object. |

## Usage Examples

### Basic Global Front Door with Forwarding

```hcl
module "frontdoor" {
  source = "../../modules/azure/frontdoor"

  name                = "contoso-web-fd"
  resource_group_name = "rg-prod-networking"
  friendly_name       = "Contoso Global Web Front Door"

  frontend_endpoints = [
    {
      name      = "default-endpoint"
      host_name = "contoso-web-fd.azurefd.net"
    }
  ]

  backend_pools = [
    {
      name                = "appServiceBackendPool"
      load_balancing_name = "defaultLoadBalancingSettings"
      health_probe_name   = "defaultHealthProbeSettings"
      backends = [
        {
          enabled     = true
          address     = "contoso-app.azurewebsites.net"
          host_header = "contoso-app.azurewebsites.net"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 100
        }
      ]
    }
  ]

  routing_rules = [
    {
      name               = "defaultRoutingRule"
      accepted_protocols = ["Http", "Https"]
      patterns_to_match  = ["/*"]
      frontend_endpoints = ["default-endpoint"]
      forwarding_configuration = {
        backend_pool_name   = "appServiceBackendPool"
        forwarding_protocol = "HttpsOnly"
      }
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
