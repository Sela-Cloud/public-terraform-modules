# Azure App Service Certificate (Custom / Self-Managed) Module

Terraform module to provision and manage a custom / self-managed [Azure App Service Certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate) (`azurerm_app_service_certificate`).

This module allows you to import your own custom certificates into Azure App Service either from an Azure Key Vault secret or by directly providing a base64-encoded PFX blob with password. It supports wildcard certificates (`*.example.com`) and apex/naked domain certificates (`example.com`).

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
| name | Specifies the name of the certificate. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the certificate. | `string` | n/a | yes |
| location | Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| key_vault_secret_id | The ID of the Key Vault Secret containing the certificate. Cannot be used when `pfx_blob` is specified. | `string` | `null` | no |
| key_vault_id | The ID of the Key Vault to associate with the certificate. | `string` | `null` | no |
| pfx_blob | The base64-encoded contents of the PKCS#12 (.pfx) file. Cannot be used when `key_vault_secret_id` is specified. | `string` | `null` | no |
| password | The password to access the certificate's private key in the PFX blob. | `string` | `null` | no |
| app_service_plan_id | The ID of the App Service Plan assigned to the certificate. | `string` | `null` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the App Service Certificate. |
| name | The name of the App Service Certificate. |
| expiration_date | The expiration date for the certificate. |
| friendly_name | The friendly name of the certificate. |
| host_names | List of host names the certificate is valid for. |
| hosting_environment_profile_id | The ID of the App Service Environment hosting environment profile. |
| issue_date | The date the certificate was issued. |
| issuer | The issuer of the certificate. |
| subject_name | The subject name of the certificate. |
| thumbprint | The thumbprint of the certificate. |
| app_service_certificate | The full Azure App Service Certificate resource object (marked sensitive). |

## Usage

### Certificate from Azure Key Vault

```hcl
module "app_service_certificate" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/app-service-certificate?ref=azure-app-service-certificate"

  name                = "cert-custom-domain"
  resource_group_name = "rg-production"
  location            = "East US"
  key_vault_secret_id = azurerm_key_vault_certificate.example.secret_id

  tags = {
    Environment = "production"
  }
}
```

### Certificate from PFX Blob

```hcl
module "app_service_certificate" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/app-service-certificate?ref=azure-app-service-certificate"

  name                = "cert-custom-domain"
  resource_group_name = "rg-production"
  location            = "East US"
  pfx_blob            = filebase64("path/to/certificate.pfx")
  password            = var.certificate_password

  tags = {
    Environment = "production"
  }
}
```
