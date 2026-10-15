# Azure Storage Queue Module

Terraform module to provision and manage an [Azure Storage Queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) (`azurerm_storage_queue`) within an Azure Storage Account.

Azure Storage Queues provide reliable asynchronous message queuing between distributed application components.

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
| name | The name of the Storage Queue. Must be between 3 and 63 characters long, contain only lowercase alphanumeric characters and hyphens, start and end with an alphanumeric character, and cannot have consecutive hyphens. | `string` | n/a | yes |
| storage_account_id | The ID of the Storage Account in which the Storage Queue should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| metadata | A mapping of metadata which should be assigned to this Storage Queue. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations (`create`, `read`, `update`, `delete`). | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Queue. |
| name | The name of the Storage Queue. |
| url | The URL of the Storage Queue. |
| storage_queue | The full Azure Storage Queue resource object. |

## Usage

### Basic Storage Queue

```hcl
module "storage_queue" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-queue?ref=azure-storage-queue"

  name               = "orders-queue"
  storage_account_id = azurerm_storage_account.example.id
}
```

### Storage Queue with Metadata

```hcl
module "storage_queue_with_metadata" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-queue?ref=azure-storage-queue"

  name               = "notifications-queue"
  storage_account_id = azurerm_storage_account.example.id

  metadata = {
    environment = "production"
    service     = "notifications"
  }
}
```
