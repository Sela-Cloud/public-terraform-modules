# AWS DataSync Frontend Module

This frontend module wraps the core AWS DataSync module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates a group of agents, locations, and tasks that together make up one DataSync deployment.

Agents, S3 locations, EFS locations, and tasks have full field-by-field UI exposure. NFS, SMB, FSx (ONTAP, OpenZFS, Windows, Lustre), generic Object Storage, Azure Blob, and HDFS locations are exposed as raw JSON for now, in the shape the corresponding Terraform resource's arguments take -- a later pass can give these their own fields.

## Usage

```hcl
module "datasync" {
  source = "./frontend/modules/aws/datasync"

  region = "us-east-1"

  datasync = {
    "my-datasync-deployment" = {
      agents = [
        { key = "onprem-agent", activation_key = "ABCDE-12345-ABCDE-12345-ABCDE" }
      ]

      s3_locations = [
        {
          key           = "s3-dest"
          s3_bucket_arn = "arn:aws:s3:::my-sync-bucket"
          s3_config = {
            bucket_access_role_arn = "arn:aws:iam::123456789012:role/datasync-s3-role"
          }
        }
      ]

      nfs_locations = jsonencode({
        "nfs-src" = {
          server_hostname = "nfs.example.com"
          subdirectory    = "/export"
          on_prem_config  = { agent_keys = ["onprem-agent"] }
        }
      })

      tasks = [
        { key = "nfs-to-s3", source_location_key = "nfs-src", destination_location_key = "s3-dest" }
      ]

      tags = {
        Environment = "production"
      }
    }
  }
}
```
