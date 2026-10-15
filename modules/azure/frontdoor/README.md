# Azure Front Door (Standard / Premium) Module

Terraform module to provision and manage an [Azure Front Door Profile (Standard or Premium)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) with endpoints, origin groups, backend origins, and routing rules.

Azure Front Door is a global, scalable entry point that uses the Microsoft global edge network to create fast, secure, and widely scalable web applications.

> **Note:** This module replaces the legacy **Azure Front Door (Classic)**, which was deprecated by Microsoft on April 1, 2025.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0, < 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Front Door profile. | `string` | n/a | yes |
| resource_group_name | Specifies the name of the Resource Group in which the Front Door profile should exist. | `string` | n/a | yes |
| sku_name | Specifies the SKU for the Front Door profile (`Standard_AzureFrontDoor` or `Premium_AzureFrontDoor`). | `string` | `"Standard_AzureFrontDoor"` | no |
| response_timeout_seconds | Specifies the maximum response timeout in seconds (16 to 240). | `number` | `120` | no |
| endpoints | A list of endpoint configurations for the Front Door profile. | `list(object)` | n/a | yes |
| origin_groups | A list of origin group configurations with backend origins, health probes, and load balancing. | `list(object)` | n/a | yes |
| routes | A list of route configurations connecting endpoints to origin groups. | `list(object)` | n/a | yes |
| tags | A mapping of tags to assign to the Front Door profile. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Front Door Profile. |
| name | The name of the Front Door Profile. |
| resource_guid | The UUID of the Front Door Profile. |
| endpoints | A map of created endpoints, including their hostnames. |
| origin_groups | A map of created origin groups and their IDs. |
| profile | The full Azure Front Door Profile resource object. |

## Usage Example

```hcl
module "frontdoor" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/frontdoor?ref=v0.9.14"

  name                = "afd-my-workload-prod"
  resource_group_name = "rg-production"
  sku_name            = "Standard_AzureFrontDoor"

  endpoints = [
    {
      name    = "ep-my-workload"
      enabled = true
    }
  ]

  origin_groups = [
    {
      name                     = "og-default"
      session_affinity_enabled = false

      load_balancing = {
        sample_size                        = 4
        successful_samples_required        = 3
        additional_latency_in_milliseconds = 50
      }

      health_probe = {
        protocol            = "Https"
        interval_in_seconds = 100
        path                = "/"
        request_type        = "HEAD"
      }

      origins = [
        {
          name                           = "primary-app-service"
          host_name                      = "app-my-workload.azurewebsites.net"
          origin_host_header             = "app-my-workload.azurewebsites.net"
          http_port                      = 80
          https_port                     = 443
          priority                       = 1
          weight                         = 1000
          certificate_name_check_enabled = true
          enabled                        = true
        }
      ]
    }
  ]

  routes = [
    {
      name                   = "route-all"
      endpoint_name          = "ep-my-workload"
      origin_group_name      = "og-default"
      forwarding_protocol    = "HttpsOnly"
      patterns_to_match      = ["/*"]
      supported_protocols    = ["Http", "Https"]
      https_redirect_enabled = true
      link_to_default_domain = true
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
