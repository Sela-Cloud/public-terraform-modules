variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "datasync" {
  description = "Map of AWS DataSync deployment configurations, keyed by deployment name."
  type = map(object({
    name                     = optional(string, "datasync-default")
    agents                   = optional(any, {})
    s3_locations             = optional(any, {})
    efs_locations            = optional(any, {})
    nfs_locations            = optional(any, {})
    smb_locations            = optional(any, {})
    fsx_ontap_locations      = optional(any, {})
    fsx_openzfs_locations    = optional(any, {})
    fsx_windows_locations    = optional(any, {})
    fsx_lustre_locations     = optional(any, {})
    object_storage_locations = optional(any, {})
    azure_blob_locations     = optional(any, {})
    hdfs_locations           = optional(any, {})
    tasks                    = optional(any, {})
    tags                     = optional(map(string), {})
  }))
  default = {
    "datasync-default" = {
      name = "datasync-default"
      tags = {
        Environment = "dev"
        ManagedBy   = "Terraform"
      }
    }
  }
}
