# Azure Role Assignment (RBAC) Module

Terraform module to provision and manage an [Azure Role Assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (`azurerm_role_assignment`) for Azure Role-Based Access Control (RBAC), supporting built-in and custom roles, attribute-based access control (ABAC) conditions, Service Principal replication lag handling, and cross-tenant delegation.

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
| scope | The scope at which the Role Assignment applies to, such as a Management Group ID, Subscription ID, Resource Group ID, or Resource ID. Changing this forces a new resource to be created. | `string` | n/a | yes |
| principal_id | The ID of the Principal (User, Group, Service Principal, or Managed Identity Object ID) to assign the Role Definition to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| role_definition_name | The name of a built-in Azure Role (e.g. `Reader`, `Contributor`, `Owner`, `Storage Blob Data Contributor`). Mutually exclusive with `role_definition_id`. | `string` | `"Reader"` | no |
| role_definition_id | The Scoped-ID of the Role Definition. Mutually exclusive with `role_definition_name`. | `string` | `null` | no |
| name | A unique UUID/GUID for this Role Assignment. If not specified or not a valid UUID, Azure/Terraform generates one automatically. Changing this forces a new resource to be created. | `string` | `null` | no |
| principal_type | The type of the `principal_id`. Possible values are `User`, `Group`, and `ServicePrincipal`. Changing this forces a new resource to be created. | `string` | `null` | no |
| description | A description for this Role Assignment. | `string` | `null` | no |
| skip_service_principal_aad_check | If the `principal_id` is a newly provisioned Service Principal, set to `true` to skip Azure Active Directory check due to replication lag. | `bool` | `false` | no |
| condition | The condition that limits the resources that the role can be assigned to (Attribute-Based Access Control / ABAC). | `string` | `null` | no |
| condition_version | The version of the condition. Possible values are `1.0` or `2.0`. | `string` | `null` | no |
| delegated_managed_identity_resource_id | The delegated Azure Resource Id which contains a Managed Identity (used in cross-tenant scenarios). Changing this forces a new resource to be created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Role Assignment. |
| name | The name of the Role Assignment (GUID). |
| scope | The scope at which the Role Assignment was applied. |
| principal_id | The ID of the Principal assigned to the role. |
| principal_type | The type of the Principal assigned to the role. |
| role_definition_id | The Scoped-ID of the Role Definition applied. |
| role_definition_name | The name of the built-in Role applied. |
| role_assignment | The full Azure Role Assignment resource object. |

## Usage

### Basic Role Assignment (Built-in Role)

```hcl
module "role_assignment" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/role-assignment?ref=v0.7.6"

  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-workload"
  role_definition_name = "Contributor"
  principal_id         = "11111111-1111-1111-1111-111111111111"
  principal_type       = "ServicePrincipal"
  description          = "Grant Contributor role to workload deployment service principal"
}
```

### Role Assignment with Custom Role Definition ID

```hcl
module "custom_role_assignment" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/role-assignment?ref=v0.7.6"

  scope              = "/subscriptions/00000000-0000-0000-0000-000000000000"
  role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/22222222-2222-2222-2222-222222222222"
  principal_id       = "11111111-1111-1111-1111-111111111111"
  principal_type     = "User"
  description        = "Grant custom security auditor role"
}
```

### Role Assignment for Newly Created Service Principal (Skip AAD Check)

```hcl
module "sp_role_assignment" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/role-assignment?ref=v0.7.6"

  scope                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data"
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = "33333333-3333-3333-3333-333333333333"
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  description                      = "Allow newly provisioned application service principal to read/write blobs"
}
```

### Role Assignment with ABAC Condition

```hcl
module "abac_role_assignment" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/role-assignment?ref=v0.7.6"

  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "11111111-1111-1111-1111-111111111111"
  principal_type       = "User"
  condition_version    = "2.0"
  condition            = <<-EOT
(
  (
    !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND
    @Request[Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags:Project] StringEquals 'Finance')
  )
)
EOT
  description          = "Constrained blob read access with ABAC project tag filter"
}
```
