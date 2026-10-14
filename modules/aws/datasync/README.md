# AWS DataSync Terraform Module

Terraform module to provision and manage [AWS DataSync](https://aws.amazon.com/datasync/) resources, including DataSync Agents, all storage location types, and synchronization tasks with configurable options, schedules, and filters.

---

## Features

- **Agent Management**: Deploy and configure AWS DataSync agents for on-premises or VPC networks.
- **Comprehensive Storage Location Support**:
  - **Amazon S3** (`aws_datasync_location_s3`)
  - **Amazon EFS** (`aws_datasync_location_efs`)
  - **Network File System (NFS)** (`aws_datasync_location_nfs`)
  - **Server Message Block (SMB)** (`aws_datasync_location_smb`)
  - **Amazon FSx for NetApp ONTAP** (`aws_datasync_location_fsx_ontap_file_system`)
  - **Amazon FSx for OpenZFS** (`aws_datasync_location_fsx_openzfs_file_system`)
  - **Amazon FSx for Windows File Server** (`aws_datasync_location_fsx_windows_file_system`)
  - **Amazon FSx for Lustre** (`aws_datasync_location_fsx_lustre_file_system`)
  - **Self-Managed Object Storage** (`aws_datasync_location_object_storage`)
  - **Azure Blob Storage** (`aws_datasync_location_azure_blob`)
  - **Hadoop Distributed File System (HDFS)** (`aws_datasync_location_hdfs`)
- **Automated Dependency Handling**: Reference locations and agents directly by key, automatically establishing dependencies without race conditions.
- **Task Configurations**: Full support for bandwidth limits, verification modes, transfer modes, include/exclude filters, and CloudWatch logging.

---

## Usage

### S3 to S3 Synchronization

```hcl
module "datasync" {
  source = "../../modules/aws/datasync"

  s3_locations = {
    "source_s3" = {
      name             = "source-s3-location"
      s3_bucket_arn    = "arn:aws:s3:::source-bucket"
      subdirectory     = "/incoming"
      s3_storage_class = "STANDARD"
      s3_config = {
        bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
      }
    }
    "dest_s3" = {
      name             = "dest-s3-location"
      s3_bucket_arn    = "arn:aws:s3:::destination-bucket"
      subdirectory     = "/archive"
      s3_storage_class = "STANDARD_IA"
      s3_config = {
        bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
      }
    }
  }

  tasks = {
    "s3_sync_task" = {
      name                     = "s3-to-s3-daily-sync"
      source_location_key      = "source_s3"
      destination_location_key = "dest_s3"

      schedule = {
        schedule_expression = "cron(0 2 * * ? *)"
      }

      options = {
        verify_mode            = "POINT_IN_TIME_CONSISTENT"
        preserve_deleted_files = "REMOVE"
        log_level              = "BASIC"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### On-Premises NFS to Amazon S3 Migration

```hcl
module "datasync" {
  source = "../../modules/aws/datasync"

  agents = {
    "onprem_agent" = {
      name           = "onprem-datasync-agent"
      activation_key = "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
      ip_address     = "10.0.1.10"
    }
  }

  nfs_locations = {
    "onprem_nfs" = {
      name            = "onprem-nfs"
      server_hostname = "nfs.internal.example.com"
      subdirectory    = "/exports/data"
      on_prem_config = {
        agent_keys = ["onprem_agent"]
      }
    }
  }

  s3_locations = {
    "backup_s3" = {
      name          = "backup-s3"
      s3_bucket_arn = "arn:aws:s3:::company-backup-bucket"
      subdirectory  = "/nfs-backup"
      s3_config = {
        bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
      }
    }
  }

  tasks = {
    "nfs_to_s3_migration" = {
      name                     = "nfs-to-s3-task"
      source_location_key      = "onprem_nfs"
      destination_location_key = "backup_s3"

      options = {
        verify_mode       = "ONLY_FILES_TRANSFERRED"
        posix_permissions = "PRESERVE"
        bytes_per_second  = 52428800 # 50 MB/s
      }
    }
  }
}
```

---

## File Structure

| File | Description |
|------|-------------|
| `main.tf` | AWS DataSync resources (Agents, all Location types, Tasks) and dependency resolution |
| `variables.tf` | Input variables |
| `outputs.tf` | Output attributes |
| `versions.tf` | Terraform and provider version constraints |
| `terraform.tfvars.example` | Example variable definitions |
| `README.md` | Module documentation |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `tags` | Map of tags to assign to resources | `map(string)` | `{}` | no |
| `agents` | Map of AWS DataSync agents | `map(object)` | `{}` | no |
| `s3_locations` | Map of S3 storage locations | `map(object)` | `{}` | no |
| `efs_locations` | Map of EFS storage locations | `map(object)` | `{}` | no |
| `nfs_locations` | Map of NFS storage locations | `map(object)` | `{}` | no |
| `smb_locations` | Map of SMB storage locations | `map(object)` | `{}` | no |
| `fsx_ontap_locations` | Map of FSx for ONTAP locations | `map(object)` | `{}` | no |
| `fsx_openzfs_locations` | Map of FSx for OpenZFS locations | `map(object)` | `{}` | no |
| `fsx_windows_locations` | Map of FSx for Windows locations | `map(object)` | `{}` | no |
| `fsx_lustre_locations` | Map of FSx for Lustre locations | `map(object)` | `{}` | no |
| `object_storage_locations` | Map of Object Storage locations | `map(object)` | `{}` | no |
| `azure_blob_locations` | Map of Azure Blob locations | `map(object)` | `{}` | no |
| `hdfs_locations` | Map of HDFS locations | `map(object)` | `{}` | no |
| `tasks` | Map of DataSync tasks | `map(object)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `agents` | Map of created agents with their IDs and ARNs |
| `s3_locations` | Map of created S3 locations with their IDs and ARNs |
| `efs_locations` | Map of created EFS locations with their IDs and ARNs |
| `nfs_locations` | Map of created NFS locations with their IDs and ARNs |
| `smb_locations` | Map of created SMB locations with their IDs and ARNs |
| `fsx_ontap_locations` | Map of created FSx for ONTAP locations with their IDs and ARNs |
| `fsx_openzfs_locations` | Map of created FSx for OpenZFS locations with their IDs and ARNs |
| `fsx_windows_locations` | Map of created FSx for Windows locations with their IDs and ARNs |
| `fsx_lustre_locations` | Map of created FSx for Lustre locations with their IDs and ARNs |
| `object_storage_locations` | Map of created Object Storage locations with their IDs and ARNs |
| `azure_blob_locations` | Map of created Azure Blob locations with their IDs and ARNs |
| `hdfs_locations` | Map of created HDFS locations with their IDs and ARNs |
| `all_locations` | Map of all created location keys to their ARNs |
| `tasks` | Map of created DataSync tasks with their IDs and ARNs |
