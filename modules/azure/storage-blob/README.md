# Azure Storage Blob Terraform Child Module

Terraform module to provision an [Azure Storage Blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob).

This module manages the Azure Storage Blob resource (`azurerm_storage_blob`), which manages files, documents, and binary data within an Azure Storage Container.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_blob.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the storage blob. Must be unique within the storage container. | `string` | `"sample-blob.txt"` | no |
| storage_container_id | The ID of the storage container in which this blob should be created. | `string` | `"/subscriptions/..."` | yes |
| type | The type of the storage blob (`Block`, `Append`, or `Page`). | `string` | `"Block"` | no |
| size | Size in bytes for Page blobs (must be a multiple of 512). | `number` | `null` | no |
| content_type | The content type of the storage blob. | `string` | `"application/octet-stream"` | no |
| source_content | The inline content for the blob (Block blobs only). | `string` | `null` | no |
| source_file | An absolute path to a file on the local system. | `string` | `null` | no |
| source_uri | The URI of an existing blob or file to use as source. | `string` | `null` | no |
| access_tier | The access tier of the storage blob (`Hot`, `Cool`, `Cold`, or `Archive`). | `string` | `"Hot"` | no |
| cache_control | Controls the Cache-Control header content of the response. | `string` | `null` | no |
| content_md5 | The MD5 sum of the blob contents. | `string` | `null` | no |
| encryption_scope | The encryption scope to use for this blob. | `string` | `null` | no |
| parallelism | Number of workers per CPU core for concurrent uploads. | `number` | `8` | no |
| metadata | A map of custom key-value pairs to assign as metadata. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Blob. |
| url | The URL of the Storage Blob. |
| name | The name of the Storage Blob. |
| storage_container_id | The ID of the Storage Container in which the blob was created. |
| type | The type of the Storage Blob. |
| access_tier | The access tier of the Storage Blob. |
| content_type | The content type of the Storage Blob. |
| metadata | The metadata assigned to the Storage Blob. |
| storage_blob | The full Azure Storage Blob resource object. |

## Usage

```hcl
module "storage_blob" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-blob?ref=v0.7.6"

  name                 = "app-config.json"
  storage_container_id = azurerm_storage_container.example.id
  type                 = "Block"
  content_type         = "application/json"
  source_content       = jsonencode({ environment = "production", debug = false })
  access_tier          = "Hot"

  metadata = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
