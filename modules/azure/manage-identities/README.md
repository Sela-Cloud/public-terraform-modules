# Azure User Assigned Managed Identity Terraform Module

Terraform module to provision and manage an [Azure User Assigned Managed Identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (`azurerm_user_assigned_identity`) with optional Azure RBAC role assignments (`azurerm_role_assignment`).

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
| name | The name of the User Assigned Identity. Changing this forces a new identity to be created. | `string` | `"uai-default"` | yes |
| resource_group_name | The name of the Resource Group in which to create the User Assigned Identity. Changing this forces a new identity to be created. | `string` | `"rg-default"` | yes |
| location | The Azure Region where the User Assigned Identity should exist. Changing this forces a new identity to be created. | `string` | `"eastus"` | yes |
| tags | A mapping of tags which should be assigned to the User Assigned Identity. | `map(string)` | `{}` | no |
| role_assignments | List of role assignments to grant to this User Assigned Managed Identity. | <pre>list(object({<br>  scope                = string<br>  role_definition_name = optional(string, null)<br>  role_definition_id   = optional(string, null)<br>  description          = optional(string, null)<br>}))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the User Assigned Identity. |
| name | The name of the User Assigned Identity. |
| principal_id | The ID of the Service Principal object associated with the created Identity. |
| client_id | The Client ID of the User Assigned Identity. |
| tenant_id | The Tenant ID of the User Assigned Identity. |
| resource_group_name | The name of the Resource Group in which the User Assigned Identity was created. |
| location | The Azure Region where the User Assigned Identity was created. |
| tags | A mapping of tags assigned to the User Assigned Identity. |
| user_assigned_identity | The full Azure User Assigned Identity resource object. |
| role_assignments | Map of created role assignments associated with this Managed Identity. |

## Usage

### Basic User Assigned Identity

```hcl
module "user_assigned_identity" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/manage-identities?ref=v0.7.6"

  name                = "uai-workload-prod"
  resource_group_name = "rg-security"
  location            = "eastus"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### User Assigned Identity with Role Assignment

```hcl
module "user_assigned_identity_with_roles" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/manage-identities?ref=v0.7.6"

  name                = "uai-app-prod"
  resource_group_name = "rg-security"
  location            = "eastus"

  role_assignments = [
    {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data"
      role_definition_name = "Storage Blob Data Contributor"
      description          = "Grant read and write access to storage containers in rg-data"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```
