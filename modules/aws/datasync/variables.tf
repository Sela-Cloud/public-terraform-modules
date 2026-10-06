################################################################################
# General / Tags Variables
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}

################################################################################
# AWS DataSync Agents
################################################################################

variable "agents" {
  description = "Map of AWS DataSync agents to deploy, keyed by agent identifier."
  type = map(object({
    name                  = optional(string)
    activation_key        = optional(string)
    ip_address            = optional(string)
    security_group_arns   = optional(list(string))
    subnet_arns           = optional(list(string))
    vpc_endpoint_id       = optional(string)
    private_link_endpoint = optional(string)
    tags                  = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - Amazon S3
################################################################################

variable "s3_locations" {
  description = "Map of AWS DataSync S3 locations to deploy, keyed by location identifier."
  type = map(object({
    name             = optional(string)
    s3_bucket_arn    = string
    subdirectory     = optional(string, "/")
    s3_storage_class = optional(string, "STANDARD")
    s3_config = object({
      bucket_access_role_arn = string
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - Amazon EFS
################################################################################

variable "efs_locations" {
  description = "Map of AWS DataSync EFS locations to deploy, keyed by location identifier."
  type = map(object({
    name                        = optional(string)
    efs_file_system_arn         = string
    subdirectory                = optional(string, "/")
    access_point_arn            = optional(string)
    file_system_access_role_arn = optional(string)
    in_transit_encryption       = optional(string, "TLS1_2")
    ec2_config = object({
      security_group_arns = list(string)
      subnet_arn          = string
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - NFS
################################################################################

variable "nfs_locations" {
  description = "Map of AWS DataSync NFS locations to deploy, keyed by location identifier."
  type = map(object({
    name            = optional(string)
    server_hostname = string
    subdirectory    = string
    on_prem_config = object({
      agent_arns = optional(list(string))
      agent_keys = optional(list(string))
    })
    mount_options = optional(object({
      version = optional(string, "AUTOMATIC")
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - SMB
################################################################################

variable "smb_locations" {
  description = "Map of AWS DataSync SMB locations to deploy, keyed by location identifier."
  type = map(object({
    name            = optional(string)
    server_hostname = string
    subdirectory    = string
    user            = string
    password        = string
    domain          = optional(string)
    agent_arns      = optional(list(string))
    agent_keys      = optional(list(string))
    mount_options = optional(object({
      version = optional(string, "AUTOMATIC")
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - FSx for NetApp ONTAP
################################################################################

variable "fsx_ontap_locations" {
  description = "Map of AWS DataSync FSx for NetApp ONTAP locations to deploy, keyed by location identifier."
  type = map(object({
    name                        = optional(string)
    storage_virtual_machine_arn = string
    security_group_arns         = list(string)
    subdirectory                = optional(string, "/")
    protocol = object({
      nfs = optional(object({
        mount_options = optional(object({
          version = optional(string, "AUTOMATIC")
        }))
      }))
      smb = optional(object({
        domain   = optional(string)
        password = string
        user     = string
        mount_options = optional(object({
          version = optional(string, "AUTOMATIC")
        }))
      }))
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - FSx for OpenZFS
################################################################################

variable "fsx_openzfs_locations" {
  description = "Map of AWS DataSync FSx for OpenZFS locations to deploy, keyed by location identifier."
  type = map(object({
    name                = optional(string)
    fsx_filesystem_arn  = string
    security_group_arns = list(string)
    subdirectory        = optional(string, "/")
    protocol = object({
      nfs = object({
        mount_options = optional(object({
          version = optional(string, "AUTOMATIC")
        }))
      })
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - FSx for Windows File Server
################################################################################

variable "fsx_windows_locations" {
  description = "Map of AWS DataSync FSx for Windows File Server locations to deploy, keyed by location identifier."
  type = map(object({
    name                = optional(string)
    fsx_filesystem_arn  = string
    security_group_arns = list(string)
    user                = string
    password            = string
    domain              = optional(string)
    subdirectory        = optional(string, "/")
    tags                = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - FSx for Lustre
################################################################################

variable "fsx_lustre_locations" {
  description = "Map of AWS DataSync FSx for Lustre locations to deploy, keyed by location identifier."
  type = map(object({
    name                = optional(string)
    fsx_filesystem_arn  = string
    security_group_arns = list(string)
    subdirectory        = optional(string, "/")
    tags                = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - Object Storage
################################################################################

variable "object_storage_locations" {
  description = "Map of AWS DataSync Object Storage locations to deploy, keyed by location identifier."
  type = map(object({
    name            = optional(string)
    server_hostname = string
    bucket_name     = string
    subdirectory    = optional(string, "/")
    agent_arns      = optional(list(string))
    agent_keys      = optional(list(string))
    access_key      = optional(string)
    secret_key      = optional(string)
    server_protocol = optional(string, "HTTPS")
    server_port     = optional(number)
    tags            = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - Azure Blob Storage
################################################################################

variable "azure_blob_locations" {
  description = "Map of AWS DataSync Azure Blob Storage locations to deploy, keyed by location identifier."
  type = map(object({
    name                = optional(string)
    container_url       = string
    authentication_type = optional(string, "SAS")
    access_tier         = optional(string, "HOT")
    subdirectory        = optional(string, "/")
    agent_arns          = optional(list(string))
    agent_keys          = optional(list(string))
    sas_configuration = optional(object({
      token = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Locations - HDFS
################################################################################

variable "hdfs_locations" {
  description = "Map of AWS DataSync HDFS locations to deploy, keyed by location identifier."
  type = map(object({
    name                = optional(string)
    authentication_type = string
    subdirectory        = optional(string, "/")
    agent_arns          = optional(list(string))
    agent_keys          = optional(list(string))
    name_nodes = list(object({
      hostname = string
      port     = number
    }))
    block_size                = optional(number)
    replication_factor        = optional(number)
    simple_user               = optional(string)
    kerberos_principal        = optional(string)
    kerberos_keytab           = optional(string)
    kerberos_keytab_base64    = optional(string)
    kerberos_krb5_conf        = optional(string)
    kerberos_krb5_conf_base64 = optional(string)
    kms_key_provider_uri      = optional(string)
    qop_configuration = optional(object({
      rpc_protection           = optional(string)
      data_transfer_protection = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# AWS DataSync Tasks
################################################################################

variable "tasks" {
  description = "Map of AWS DataSync tasks to deploy, keyed by task identifier."
  type = map(object({
    name                     = optional(string)
    source_location_arn      = optional(string)
    source_location_key      = optional(string)
    destination_location_arn = optional(string)
    destination_location_key = optional(string)
    cloudwatch_log_group_arn = optional(string)
    schedule = optional(object({
      schedule_expression = string
    }))
    options = optional(object({
      atime                          = optional(string)
      bytes_per_second               = optional(number)
      gid                            = optional(string)
      log_level                      = optional(string)
      mtime                          = optional(string)
      overwrite_mode                 = optional(string)
      posix_permissions              = optional(string)
      preserve_deleted_files         = optional(string)
      preserve_devices               = optional(string)
      security_descriptor_copy_flags = optional(string)
      task_queueing                  = optional(string)
      transfer_mode                  = optional(string)
      uid                            = optional(string)
      verify_mode                    = optional(string)
    }))
    includes = optional(object({
      filter_type = optional(string, "SIMPLE_PATTERN")
      value       = string
    }))
    excludes = optional(object({
      filter_type = optional(string, "SIMPLE_PATTERN")
      value       = string
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}
