# Azure Function App Terraform Child Module

Terraform module to provision an [Azure Function App](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app), its hosting [App Service Plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan), and required backend [Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account).

This module manages Azure Function App for both **Linux** and **Windows** operating systems, supporting Consumption (Serverless `Y1`), Elastic Premium (`EP1`), and Dedicated App Service Plans, auto-provisioned or existing storage accounts, VNet integration, Managed Identities, application runtime stacks, CORS, and connection strings.

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
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_linux_function_app.linux_function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_windows_function_app.windows_function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Azure Function App (must be globally unique across Azure). | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group in which to create the Function App. | `string` | n/a | yes |
| location | The Azure Region where the Function App should exist. | `string` | n/a | yes |
| os_type | The operating system type (`Linux` or `Windows`). | `string` | `"Linux"` | no |
| create_service_plan | Whether to create a new App Service Plan. Set to `false` when passing `service_plan_id`. | `bool` | `true` | no |
| service_plan_name | Custom name for the new Service Plan. Defaults to `asp-<name>` if null. | `string` | `null` | no |
| service_plan_sku | The SKU for the Service Plan (e.g. `Y1` for Consumption, `B1`, `S1`, `EP1`). | `string` | `"Y1"` | no |
| service_plan_id | Resource ID of an existing Service Plan to use. | `string` | `null` | no |
| zone_balancing_enabled | Enable availability zone balancing for the service plan. | `bool` | `false` | no |
| create_storage_account | Whether to automatically create a backend Storage Account if not supplied. | `bool` | `true` | no |
| storage_account_name | Backend Storage Account name. If null and `create_storage_account` is true, an auto-generated name is used. | `string` | `null` | no |
| storage_account_access_key | Access key for an existing backend Storage Account. | `string` | `null` | no |
| storage_uses_managed_identity | Use Managed Identity for storage account authentication. | `bool` | `false` | no |
| storage_account_tier | Tier for the created Storage Account (`Standard` or `Premium`). | `string` | `"Standard"` | no |
| storage_account_replication_type | Replication type for created Storage Account (`LRS`, `GRS`, `ZRS`). | `string` | `"LRS"` | no |
| https_only | Redirect all HTTP traffic to HTTPS. | `bool` | `true` | no |
| client_certificate_enabled | Enable mutual TLS client certificate authentication. | `bool` | `false` | no |
| client_certificate_mode | Client cert mode (`Required`, `Optional`, `OptionalInteractiveUser`). | `string` | `null` | no |
| public_network_access_enabled | Allow public network ingress to this Function App. | `bool` | `true` | no |
| virtual_network_subnet_id | Delegated subnet ID for outbound regional VNet integration. | `string` | `null` | no |
| builtin_logging_enabled | Enable built-in logging. | `bool` | `true` | no |
| functions_extension_version | Azure Functions runtime version. | `string` | `"~4"` | no |
| identity_type | Type of Managed Identity (`SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`). | `string` | `null` | no |
| identity_ids | List of User-Assigned Identity IDs. | `list(string)` | `[]` | no |
| app_settings | Key-value application settings / environment variables. | `map(string)` | `{}` | no |
| site_config | Site configuration block (application stack, cors, ip restrictions). | `any` | `{}` | no |
| connection_strings | List of database or external service connection strings. | `list(object)` | `[]` | no |
| tags | Resource tags to assign to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|:---------:|
| id | The ID of the Azure Function App. | no |
| name | The name of the Azure Function App. | no |
| default_hostname | The default hostname associated with the Function App. | no |
| service_plan_id | The ID of the App Service Plan associated with this Function App. | no |
| storage_account_name | The name of the backend Storage Account used by the Function App. | no |
| storage_account_id | The ID of the auto-created backend Storage Account, if created. | no |
| outbound_ip_addresses | Comma-separated list of outbound IP addresses used by the Function App. | no |
| possible_outbound_ip_addresses | Comma-separated list of all possible outbound IP addresses. | no |
| identity_principal_id | Principal ID of the System-Assigned Managed Identity, if enabled. | no |
| identity_tenant_id | Tenant ID of the System-Assigned Managed Identity, if enabled. | no |
| function_app | The full Azure Function App resource object. | yes |
