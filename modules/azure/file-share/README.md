# Azure File Share Terraform Child Module

Terraform module to provision an [Azure Storage File Share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share).

Azure Files offers fully managed file shares in the cloud that are accessible via the industry-standard Server Message Block (SMB) protocol or Network File System (NFS) protocol. Azure file shares can be mounted concurrently by cloud or on-premises deployments of Windows, Linux, and macOS.

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
| [azurerm_storage_share.share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the share. | `string` | n/a | yes |
| storage_account_id | The Resource ID or name of the Storage Account. | `string` | n/a | yes |
| quota | The maximum size of the share in GB. | `number` | `50` | no |
| access_tier | Access tier (`TransactionOptimized`, `Hot`, `Cool`, `Premium`). | `string` | `null` | no |
| enabled_protocol | Protocol used (`SMB`, `NFS`). | `string` | `"SMB"` | no |
| metadata | Custom metadata key-value pairs for the share. | `map(string)` | `{}` | no |
| acl | Stored access policies for the share. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the File Share. |
| name | The name of the File Share. |
| quota | The quota of the File Share in GB. |
| url | The URL of the File Share. |
| file_share | The full Azure Storage File Share resource object. |

## Usage Examples

```hcl
module "file_share" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/file-share?ref=azure-file-share"

  name               = "team-shared-files"
  storage_account_id = azurerm_storage_account.example.id
  quota              = 100
  access_tier        = "Hot"
  enabled_protocol   = "SMB"

  metadata = {
    Environment = "production"
    Department  = "engineering"
  }
}
```
