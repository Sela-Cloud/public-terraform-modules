# Azure App Service Managed Certificate Module

Terraform module to provision and manage an [Azure App Service Managed Certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_managed_certificate) (`azurerm_app_service_managed_certificate`).

This certificate secures custom domains on Azure App Services (Windows and Linux Web Apps) hosted on an App Service Plan of tier Basic and above (Free and Shared tiers are not supported by Azure for managed certificates).

> **Note:** A certificate is valid for six months. Azure automatically renews and rotates the certificate approximately one month before expiration without requiring resource modification or reprovisioning.

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
| custom_hostname_binding_id | The ID of the App Service Custom Hostname Binding for the Certificate. Changing this forces a new App Service Managed Certificate to be created. | `string` | n/a | yes |
| tags | A mapping of tags which should be assigned to the App Service Managed Certificate. | `map(string)` | `{}` | no |
| name | An optional identifier or name for the managed certificate configuration. | `string` | `null` | no |
| timeouts | Custom timeout durations for resource operations (`create`, `read`, `update`, `delete`). | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the App Service Managed Certificate. |
| canonical_name | The Canonical Name of the Certificate. |
| expiration_date | The expiration date of the Certificate. |
| friendly_name | The friendly name of the Certificate. |
| host_names | The list of Host Names for the Certificate. |
| issue_date | The Start date for the Certificate. |
| issuer | The issuer of the Certificate. |
| subject_name | The Subject Name for the Certificate. |
| thumbprint | The Certificate Thumbprint. |
| app_service_managed_certificate | The full Azure App Service Managed Certificate resource object. |

## Usage

### Basic Managed Certificate

```hcl
module "app_service_managed_certificate" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service-managed-certificate?ref=v0.7.6"

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.example.id

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Complete End-to-End Workflow with App Service & SSL Binding

```hcl
# 1. Custom Hostname Binding
resource "azurerm_app_service_custom_hostname_binding" "example" {
  hostname            = "www.example.com"
  app_service_name    = azurerm_linux_web_app.example.name
  resource_group_name = azurerm_resource_group.example.name
}

# 2. Managed Certificate Module
module "app_service_managed_certificate" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/app-service-managed-certificate?ref=v0.7.6"

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.example.id

  tags = {
    Environment = "production"
  }
}

# 3. SSL / TLS SNI Binding
resource "azurerm_app_service_certificate_binding" "example" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.example.id
  certificate_id      = module.app_service_managed_certificate.id
  ssl_state           = "SniEnabled"
}
```
