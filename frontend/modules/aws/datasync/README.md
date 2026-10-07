# AWS DataSync Frontend Module

This is the Sela Craft frontend root module for deploying AWS DataSync configurations. It wraps the [`modules/aws/datasync`](../../../../modules/aws/datasync) child module using Terraform's `for_each` meta-argument.

---

## Architecture

```text
frontend/modules/aws/datasync (Root Wrapper Module)
  │ (for_each = var.datasync)
  ▼
modules/aws/datasync (Child Module)
  ├── aws_datasync_agent
  ├── aws_datasync_location_s3
  ├── aws_datasync_location_efs
  ├── aws_datasync_location_nfs
  ├── aws_datasync_location_smb
  ├── aws_datasync_location_fsx_ontap_file_system
  ├── aws_datasync_location_fsx_openzfs_file_system
  ├── aws_datasync_location_fsx_windows_file_system
  ├── aws_datasync_location_fsx_lustre_file_system
  ├── aws_datasync_location_object_storage
  ├── aws_datasync_location_azure_blob
  ├── aws_datasync_location_hdfs
  └── aws_datasync_task
```

---

## Quick Start

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review execution plan:
   ```bash
   terraform plan
   ```

4. Apply changes:
   ```bash
   terraform apply
   ```

---

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `region` | The AWS region where resources will be provisioned | `string` | `"us-east-1"` | yes |
| `datasync` | Map of AWS DataSync deployment configurations | `map(object({...}))` | Sample default configuration | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `datasync` | Map of deployed AWS DataSync modules and their created resources |
