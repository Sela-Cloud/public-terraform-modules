variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "datasync" {
  description = "Map of AWS DataSync deployment configurations, keyed by deployment name."
  type = map(object({
    name = optional(string, null)

    agents = optional(list(object({
      key                   = string
      name                  = optional(string, null)
      activation_key        = optional(string, null)
      ip_address            = optional(string, null)
      security_group_arns   = optional(list(string), null)
      subnet_arns           = optional(list(string), null)
      vpc_endpoint_id       = optional(string, null)
      private_link_endpoint = optional(string, null)
      tags                  = optional(map(string), {})
    })), [])

    s3_locations = optional(list(object({
      key              = string
      name             = optional(string, null)
      s3_bucket_arn    = string
      subdirectory     = optional(string, "/")
      s3_storage_class = optional(string, "STANDARD")
      s3_config = object({
        bucket_access_role_arn = string
      })
      tags = optional(map(string), {})
    })), [])

    efs_locations = optional(list(object({
      key                         = string
      name                        = optional(string, null)
      efs_file_system_arn         = string
      subdirectory                = optional(string, "/")
      access_point_arn            = optional(string, null)
      file_system_access_role_arn = optional(string, null)
      in_transit_encryption       = optional(string, "TLS1_2")
      ec2_config = object({
        security_group_arns = list(string)
        subnet_arn          = string
      })
      tags = optional(map(string), {})
    })), [])

    # Deferred location types: exposed in the UI as raw JSON text (matching the child module's own
    # map(object(...)) shape for each), not as repeatable sections, given the combined size of 9
    # more deeply-nested location schemas. jsondecode()'d in main.tf before being passed through.
    nfs_locations            = optional(string, null)
    smb_locations            = optional(string, null)
    fsx_ontap_locations      = optional(string, null)
    fsx_openzfs_locations    = optional(string, null)
    fsx_windows_locations    = optional(string, null)
    fsx_lustre_locations     = optional(string, null)
    object_storage_locations = optional(string, null)
    azure_blob_locations     = optional(string, null)
    hdfs_locations           = optional(string, null)

    tasks = optional(list(object({
      key                      = string
      name                     = optional(string, null)
      source_location_arn      = optional(string, null)
      source_location_key      = optional(string, null)
      destination_location_arn = optional(string, null)
      destination_location_key = optional(string, null)
      cloudwatch_log_group_arn = optional(string, null)
      schedule = optional(object({
        schedule_expression = string
      }), null)
      options = optional(object({
        atime                          = optional(string, null)
        bytes_per_second               = optional(number, null)
        gid                            = optional(string, null)
        log_level                      = optional(string, null)
        mtime                          = optional(string, null)
        overwrite_mode                 = optional(string, null)
        posix_permissions              = optional(string, null)
        preserve_deleted_files         = optional(string, null)
        preserve_devices               = optional(string, null)
        security_descriptor_copy_flags = optional(string, null)
        task_queueing                  = optional(string, null)
        transfer_mode                  = optional(string, null)
        uid                            = optional(string, null)
        verify_mode                    = optional(string, null)
      }), null)
      includes = optional(object({
        filter_type = optional(string, "SIMPLE_PATTERN")
        value       = string
      }), null)
      excludes = optional(object({
        filter_type = optional(string, "SIMPLE_PATTERN")
        value       = string
      }), null)
      tags = optional(map(string), {})
    })), [])

    tags = optional(map(string), {})
  }))
  default = {}
}
