# Azure App Service Terraform Child Module

Terraform module to provision an [Azure App Service (Web App)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) and its hosting [App Service Plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan).

This module manages Azure App Service for both **Linux** and **Windows** operating systems, supporting dedicated Service Plan creation or attaching to an existing Service Plan, VNet integration, Managed Identities, application runtime stacks, CORS, and connection strings.

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
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_linux_web_app.linux_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_windows_web_app.windows_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Azure App Service (must be globally unique). | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which to create the App Service. | `string` | n/a | yes |
| location | The Azure Region where the App Service should exist. | `string` | n/a | yes |
| os_type | The operating system type (`Linux` or `Windows`). | `string` | `"Linux"` | no |
| create_service_plan | Whether to create a new App Service Plan. Set to `false` when passing `service_plan_id`. | `bool` | `true` | no |
| service_plan_name | Custom name for the new Service Plan. Defaults to `asp-<name>` if null. | `string` | `null` | no |
| service_plan_sku | The SKU for the new Service Plan (e.g. `B1`, `S1`, `P1v3`). | `string` | `"B1"` | no |
| service_plan_id | Resource ID of an existing Service Plan to use. | `string` | `null` | no |
| zone_balancing_enabled | Enable availability zone balancing for the service plan. | `bool` | `false` | no |
| https_only | Redirect all HTTP traffic to HTTPS. | `bool` | `true` | no |
| client_affinity_enabled | Enable session sticky cookies (ARR affinity). | `bool` | `false` | no |
| client_certificate_enabled | Enable mutual TLS client certificate authentication. | `bool` | `false` | no |
| client_certificate_mode | Client cert mode (`Required`, `Optional`, `OptionalInteractiveUser`). | `string` | `null` | no |
| public_network_access_enabled | Allow public network ingress to this web app. | `bool` | `true` | no |
| virtual_network_subnet_id | Subnet ID for regional outbound VNet integration. | `string` | `null` | no |
| identity_type | Managed Identity type (`SystemAssigned`, `UserAssigned`, or null). | `string` | `"SystemAssigned"` | no |
| identity_ids | List of User Assigned Identity IDs when using UserAssigned. | `list(string)` | `[]` | no |
| app_settings | Key-value pairs for environment variables and app settings. | `map(string)` | `{}` | no |
| site_config | Site configuration for application runtime, TLS, FTPS, and CORS. | `object` | `{}` | no |
| connection_strings | List of database/service connection strings. | `list(object)` | `[]` | no |
| storage_mounts | List of custom storage account shares to mount. | `list(object)` | `[]` | no |
| tags | A mapping of tags to assign to the App Service. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the App Service (Web App). |
| name | The name of the App Service. |
| default_hostname | The default FQDN of the App Service (e.g. `myapp.azurewebsites.net`). |
| service_plan_id | The ID of the App Service Plan associated with this App Service. |
| outbound_ip_addresses | Comma-separated list of outbound IP addresses used by the App Service. |
| possible_outbound_ip_addresses | Comma-separated list of all possible outbound IP addresses. |
| identity_principal_id | Principal ID of the System-Assigned Managed Identity, if enabled. |
| identity_tenant_id | Tenant ID of the System-Assigned Managed Identity, if enabled. |
| web_app | The full Azure Web App resource object. |

## Usage Examples

### Example 1: Linux Web App with Dedicated Service Plan and Node.js Stack

```hcl
module "app_service_linux" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service?ref=v0.7.6"

  name                = "app-myapi-prod"
  resource_group_name = "rg-myworkload-prod"
  location            = "eastus"
  os_type             = "Linux"
  service_plan_sku    = "B1"

  site_config = {
    always_on           = true
    ftps_state          = "FtpsOnly"
    minimum_tls_version = "1.2"
    application_stack = {
      node_version = "20-lts"
    }
  }

  app_settings = {
    NODE_ENV = "production"
    PORT     = "8080"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Example 2: Windows Web App with .NET on an Existing Service Plan

```hcl
module "app_service_windows" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service?ref=v0.7.6"

  name                = "app-legacyportal-prod"
  resource_group_name = "rg-shared-prod"
  location            = "eastus"
  os_type             = "Windows"
  create_service_plan = false
  service_plan_id     = "/subscriptions/.../resourceGroups/rg-shared-prod/providers/Microsoft.Web/serverFarms/asp-shared-prod"

  site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "v8.0"
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Example 3: Enterprise Web App with VNet Integration and Managed Identity

```hcl
module "app_service_enterprise" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service?ref=v0.7.6"

  name                      = "app-finance-prod"
  resource_group_name       = "rg-finance-prod"
  location                  = "eastus"
  os_type                   = "Linux"
  service_plan_sku          = "P1v3"
  virtual_network_subnet_id = "/subscriptions/.../resourceGroups/rg-finance-prod/providers/Microsoft.Network/virtualNetworks/vnet-finance/subnets/snet-appservice"

  identity_type = "SystemAssigned"

  site_config = {
    always_on           = true
    minimum_tls_version = "1.2"
    health_check_path   = "/healthz"
    application_stack = {
      python_version = "3.11"
    }
  }

  tags = {
    Environment = "production"
    Department  = "Finance"
  }
}
```
