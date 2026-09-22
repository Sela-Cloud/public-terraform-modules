# Azure Storage Account Terraform Child Module

Terraform module to provision an [Azure Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account).

This module manages the Azure Storage Account resource (`azurerm_storage_account`), providing scalable, secure cloud storage for blobs, files, queues, tables, and Azure Data Lake Storage Gen2.

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
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the storage account (3-24 lowercase alphanumerics). | `string` | `"stdefault001"` | no |
| resource_group_name | The name of the Resource Group in which to create the Storage Account. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Storage Account should exist. | `string` | `"eastus"` | no |
| account_tier | The Tier to use for this storage account (`Standard` or `Premium`). | `string` | `"Standard"` | no |
| account_replication_type | The replication type (`LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, or `RAGZRS`). | `string` | `"LRS"` | no |
| account_kind | The Kind of account (`StorageV2`, `Storage`, `BlobStorage`, etc.). | `string` | `"StorageV2"` | no |
| access_tier | The access tier (`Hot`, `Cool`, or `Cold`). | `string` | `"Hot"` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region. | `string` | `null` | no |
| https_traffic_only_enabled | Forces HTTPS traffic only. | `bool` | `true` | no |
| min_tls_version | Minimum supported TLS version (`TLS1_2`). | `string` | `"TLS1_2"` | no |
| allow_nested_items_to_be_public | Allow nested items within the account to opt into being public. | `bool` | `false` | no |
| shared_access_key_enabled | Permits requests authorized with account access key via Shared Key. | `bool` | `true` | no |
| public_network_access_enabled | Whether public network access is enabled for the storage account. | `bool` | `true` | no |
| default_to_oauth_authentication | Default to Azure AD authorization in Azure portal. | `bool` | `false` | no |
| is_hns_enabled | Enable Hierarchical Namespace (ADLS Gen2). | `bool` | `false` | no |
| nfsv3_enabled | Enable NFSv3 protocol. | `bool` | `false` | no |
| large_file_share_enabled | Enable Large File Shares. | `bool` | `false` | no |
| cross_tenant_replication_enabled | Enable cross-tenant replication. | `bool` | `false` | no |
| infrastructure_encryption_enabled | Enable infrastructure encryption. | `bool` | `false` | no |
| sftp_enabled | Enable SFTP support (requires `is_hns_enabled = true`). | `bool` | `false` | no |
| network_rules | Network access rules (default action, bypass, IP rules, subnets). | `object` | `null` | no |
| blob_properties | Blob service properties (versioning, change feed, soft delete). | `object` | `null` | no |
| identity | Managed Identity configuration (`SystemAssigned`, `UserAssigned`). | `object` | `null` | no |
| tags | A mapping of tags to assign to the storage account. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Account. |
| name | The Name of the Storage Account. |
| resource_group_name | The Resource Group of the Storage Account. |
| location | The Azure Region of the Storage Account. |
| primary_location | The primary location of the Storage Account. |
| secondary_location | The secondary location of the Storage Account. |
| primary_blob_endpoint | The endpoint URL for blob storage in the primary location. |
| primary_blob_host | The hostname for blob storage in the primary location. |
| primary_queue_endpoint | The endpoint URL for queue storage in the primary location. |
| primary_table_endpoint | The endpoint URL for table storage in the primary location. |
| primary_file_endpoint | The endpoint URL for file storage in the primary location. |
| primary_dfs_endpoint | The endpoint URL for DFS storage in the primary location. |
| primary_web_endpoint | The endpoint URL for web storage in the primary location. |
| primary_access_key | The primary access key (sensitive). |
| secondary_access_key | The secondary access key (sensitive). |
| primary_connection_string | The primary connection string (sensitive). |
| secondary_connection_string | The secondary connection string (sensitive). |
| identity | The Managed Service Identity configuration block. |
| storage_account | The full Azure Storage Account resource object (sensitive). |

## Usage

```hcl
module "storage_account" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-account?ref=v0.7.6"

  name                     = "stmyproductionapp01"
  resource_group_name      = "rg-workload-prod"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  blob_properties = {
    versioning_enabled           = true
    delete_retention_policy_days = 14
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
