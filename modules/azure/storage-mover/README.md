# Azure Storage Mover Terraform Child Module

Terraform module to provision an [Azure Storage Mover](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover) and its associated resources including agents, projects, source endpoints (NFS), target endpoints (Azure Storage Blobs), and job definitions.

Azure Storage Mover is a fully managed hybrid data migration service designed to migrate on-premises files and folders into Azure Storage containers.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.104.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.104.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_mover.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover) | resource |
| [azurerm_storage_mover_agent.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover_agent) | resource |
| [azurerm_storage_mover_project.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover_project) | resource |
| [azurerm_storage_mover_source_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover_source_endpoint) | resource |
| [azurerm_storage_mover_target_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover_target_endpoint) | resource |
| [azurerm_storage_mover_job_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_mover_job_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Storage Mover. | `string` | n/a | yes |
| resource_group_name | Specifies the name of the Resource Group in which the Storage Mover should exist. | `string` | n/a | yes |
| location | Specifies the Azure Region where the Storage Mover should exist. | `string` | n/a | yes |
| description | A description for the Storage Mover. | `string` | `null` | no |
| tags | A mapping of tags which should be assigned to the Storage Mover. | `map(string)` | `{}` | no |
| agents | Map of Storage Mover Agents to register with the Storage Mover. | `map(object)` | `{}` | no |
| projects | Map of Storage Mover Projects to create within the Storage Mover. | `map(object)` | `{}` | no |
| source_endpoints | Map of Storage Mover Source Endpoints (NFS) to create. | `map(object)` | `{}` | no |
| target_endpoints | Map of Storage Mover Target Endpoints (Azure Storage Container) to create. | `map(object)` | `{}` | no |
| job_definitions | Map of Storage Mover Job Definitions to create within projects. | `map(object)` | `{}` | no |

### Sub-Resource Objects

#### `agents`
| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| `name` | The name of the Storage Mover Agent (defaults to map key). | `string` | no |
| `arc_virtual_machine_id` | The Azure Arc VM resource ID. | `string` | yes |
| `arc_virtual_machine_uuid` | The Azure Arc VM UUID. | `string` | yes |
| `description` | Description for the agent. | `string` | no |

#### `projects`
| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| `name` | The name of the Project (defaults to map key). | `string` | no |
| `description` | Description for the project. | `string` | no |

#### `source_endpoints` (NFS)
| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| `name` | The name of the Source Endpoint (defaults to map key). | `string` | no |
| `host` | The IP address or FQDN of the NFS server. | `string` | yes |
| `export` | The directory export path on the NFS server. | `string` | no |
| `nfs_version` | The NFS protocol version (`NFSauto`, `NFSv3`, `NFSv4`). | `string` | no (`"NFSauto"`) |
| `description` | Description for the source endpoint. | `string` | no |

#### `target_endpoints` (Azure Storage Blob)
| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| `name` | The name of the Target Endpoint (defaults to map key). | `string` | no |
| `storage_account_id` | The resource ID of the target Storage Account. | `string` | yes |
| `storage_container_name` | The name of the target blob container. | `string` | yes |
| `description` | Description for the target endpoint. | `string` | no |

#### `job_definitions`
| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| `name` | The name of the Job Definition (defaults to map key). | `string` | no |
| `project_name` | Key/name of the project defined in `projects`. | `string` | no |
| `storage_mover_project_id` | Resource ID of the project (if referencing existing project). | `string` | no |
| `source_name` | Name of the source endpoint. | `string` | yes |
| `target_name` | Name of the target endpoint. | `string` | yes |
| `copy_mode` | Copy mode (`Additive` or `Mirror`). | `string` | no (`"Additive"`) |
| `agent_name` | Optional agent name assigned to run the job definition. | `string` | no |
| `source_sub_path` | Subpath to migrate from source endpoint. | `string` | no |
| `target_sub_path` | Subpath to migrate into target endpoint. | `string` | no |
| `description` | Description for the job definition. | `string` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Mover. |
| name | The name of the Storage Mover. |
| resource_group_name | The name of the Resource Group in which the Storage Mover exists. |
| location | The Azure Region where the Storage Mover exists. |
| projects | A map of all Storage Mover Projects created. |
| agents | A map of all Storage Mover Agents created. |
| source_endpoints | A map of all Storage Mover Source Endpoints created. |
| target_endpoints | A map of all Storage Mover Target Endpoints created. |
| job_definitions | A map of all Storage Mover Job Definitions created. |

## Usage Examples

### Full Storage Mover Deployment

```hcl
module "storage_mover" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/storage-mover?ref=azure-wip"

  name                = "sm-migration-eastus"
  resource_group_name = "rg-data-migration"
  location            = "eastus"
  description         = "Storage Mover instance for on-prem NFS data migration"

  projects = {
    "project-datacenter-migration" = {
      description = "Migration of on-premises file servers to Azure Blob storage"
    }
  }

  source_endpoints = {
    "nfs-onprem-fileshare" = {
      host        = "nfs.internal.corp"
      export      = "/mnt/data"
      nfs_version = "NFSv3"
      description = "On-premises primary NFS file share"
    }
  }

  target_endpoints = {
    "blob-archive-container" = {
      storage_account_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-migration/providers/Microsoft.Storage/storageAccounts/stdataarchive"
      storage_container_name = "migration-target"
      description            = "Target container in Azure Storage Account"
    }
  }

  job_definitions = {
    "sync-nfs-to-blob" = {
      project_name    = "project-datacenter-migration"
      source_name     = "nfs-onprem-fileshare"
      target_name     = "blob-archive-container"
      copy_mode       = "Additive"
      source_sub_path = "finance/"
      target_sub_path = "finance/"
      description     = "Additive copy of finance directories"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
