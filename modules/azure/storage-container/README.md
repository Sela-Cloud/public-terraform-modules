# Azure Storage Container Terraform Child Module

Terraform module to provision an [Azure Storage Container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) with optional [Azure Storage Blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) objects.

Azure Storage Containers organize a set of blobs, similar to a directory in a file system. A storage account can include an unlimited number of containers, and a container can store an unlimited number of blobs.

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
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_blob.blobs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Storage Container. | `string` | n/a | yes |
| storage_account_id | The Resource ID or name of the Storage Account. | `string` | n/a | yes |
| container_access_type | The Access Level (`private`, `blob`, `container`). | `string` | `"private"` | no |
| default_encryption_scope | Default encryption scope for blobs in this container. | `string` | `null` | no |
| encryption_scope_override_enabled | Whether blob-level encryption scope override is enabled. | `bool` | `false` | no |
| metadata | Custom metadata key-value pairs for the container. | `map(string)` | `{}` | no |
| blobs | List of storage blobs to provision in the container. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Container. |
| name | The name of the Storage Container. |
| container_access_type | The Access Level configured for this Container. |
| container | The full Storage Container resource object. |
| blobs | Map of created storage blob resource objects. |

## Usage Examples

```hcl
module "storage_container" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-container?ref=azure-storage-container"

  name                  = "data-exports"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"

  metadata = {
    Environment = "production"
    Tier        = "backend"
  }
}
```
