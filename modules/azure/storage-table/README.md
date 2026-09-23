# Azure Storage Table Module

Terraform module to provision and manage an [Azure Storage Table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) (`azurerm_storage_table`) within an Azure Storage Account.

Azure Storage Tables provide schemaless, NoSQL key-value structured data storage suitable for high-volume datasets.

> **Note on Authentication:** Stored Access Policies (`acl` blocks) require Shared Key authentication on the Storage Account. If Shared Key access is disabled (e.g. enforcing Microsoft Entra ID-only authentication), ACL blocks cannot be applied.

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
| name | The name of the storage table. Only alphanumeric characters allowed, starting with a letter, 3-63 characters. Changing this forces a new resource to be created. | `string` | `"mysampletable"` | yes |
| storage_account_id | The ID of the Storage Account in which the Table should be created. Changing this forces a new resource to be created. | `string` | `"..."` | yes |
| acl | One or more `acl` blocks defining stored access policies for the Table. | <pre>list(object({<br>  id = string<br>  access_policy = optional(object({<br>    permissions = string<br>    start       = optional(string, null)<br>    expiry      = optional(string, null)<br>  }), null)<br>}))</pre> | `[]` | no |
| timeouts | Custom timeout durations for resource operations (`create`, `read`, `update`, `delete`). | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Table. |
| resource_manager_id | The Resource Manager ID of the Storage Table. |
| storage_table | The full Azure Storage Table resource object. |

## Usage

### Basic Storage Table

```hcl
module "storage_table" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-table?ref=v0.7.6"

  name               = "appcustomers"
  storage_account_id = azurerm_storage_account.example.id
}
```

### Storage Table with Stored Access Policy (ACL)

```hcl
module "storage_table_with_acl" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-table?ref=v0.7.6"

  name               = "auditlogs"
  storage_account_id = azurerm_storage_account.example.id

  acl = [
    {
      id = "PolicyReadWrite2026"
      access_policy = {
        permissions = "rwdl"
        start       = "2026-01-01T00:00:00Z"
        expiry      = "2026-12-31T23:59:59Z"
      }
    }
  ]
}
```
