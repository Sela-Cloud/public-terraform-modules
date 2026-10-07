################################################################################
# AWS DataSync Module - Main Configuration
################################################################################

locals {
  # Aggregated lookup map of all location ARNs created in this module
  all_location_arns = merge(
    { for k, v in aws_datasync_location_s3.this : k => v.arn },
    { for k, v in aws_datasync_location_efs.this : k => v.arn },
    { for k, v in aws_datasync_location_nfs.this : k => v.arn },
    { for k, v in aws_datasync_location_smb.this : k => v.arn },
    { for k, v in aws_datasync_location_fsx_ontap_file_system.this : k => v.arn },
    { for k, v in aws_datasync_location_fsx_openzfs_file_system.this : k => v.arn },
    { for k, v in aws_datasync_location_fsx_windows_file_system.this : k => v.arn },
    { for k, v in aws_datasync_location_fsx_lustre_file_system.this : k => v.arn },
    { for k, v in aws_datasync_location_object_storage.this : k => v.arn },
    { for k, v in aws_datasync_location_azure_blob.this : k => v.arn },
    { for k, v in aws_datasync_location_hdfs.this : k => v.arn }
  )
}

################################################################################
# AWS DataSync Agent
################################################################################

resource "aws_datasync_agent" "this" {
  for_each = var.agents

  name                  = coalesce(each.value.name, each.key)
  activation_key        = each.value.activation_key
  ip_address            = each.value.ip_address
  security_group_arns   = each.value.security_group_arns
  subnet_arns           = each.value.subnet_arns
  vpc_endpoint_id       = each.value.vpc_endpoint_id
  private_link_endpoint = each.value.private_link_endpoint

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - Amazon S3
################################################################################

resource "aws_datasync_location_s3" "this" {
  for_each = var.s3_locations

  s3_bucket_arn = each.value.s3_bucket_arn
  subdirectory  = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"

  s3_config {
    bucket_access_role_arn = each.value.s3_config.bucket_access_role_arn
  }

  s3_storage_class = each.value.s3_storage_class

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - Amazon EFS
################################################################################

resource "aws_datasync_location_efs" "this" {
  for_each = var.efs_locations

  efs_file_system_arn = each.value.efs_file_system_arn
  subdirectory        = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"

  ec2_config {
    security_group_arns = each.value.ec2_config.security_group_arns
    subnet_arn          = each.value.ec2_config.subnet_arn
  }

  file_system_access_role_arn = each.value.file_system_access_role_arn
  in_transit_encryption       = each.value.in_transit_encryption
  access_point_arn            = each.value.access_point_arn

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - NFS
################################################################################

resource "aws_datasync_location_nfs" "this" {
  for_each = var.nfs_locations

  server_hostname = each.value.server_hostname
  subdirectory    = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"

  on_prem_config {
    agent_arns = length(coalesce(each.value.on_prem_config.agent_arns, [])) > 0 ? each.value.on_prem_config.agent_arns : [
      for agent_key in coalesce(each.value.on_prem_config.agent_keys, []) : aws_datasync_agent.this[agent_key].arn
    ]
  }

  dynamic "mount_options" {
    for_each = each.value.mount_options != null ? [each.value.mount_options] : []
    content {
      version = mount_options.value.version
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [aws_datasync_agent.this]
}

################################################################################
# AWS DataSync Location - SMB
################################################################################

resource "aws_datasync_location_smb" "this" {
  for_each = var.smb_locations

  server_hostname = each.value.server_hostname
  subdirectory    = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"
  user            = each.value.user
  password        = each.value.password
  domain          = each.value.domain

  agent_arns = length(coalesce(each.value.agent_arns, [])) > 0 ? each.value.agent_arns : [
    for agent_key in coalesce(each.value.agent_keys, []) : aws_datasync_agent.this[agent_key].arn
  ]

  dynamic "mount_options" {
    for_each = each.value.mount_options != null ? [each.value.mount_options] : []
    content {
      version = mount_options.value.version
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [aws_datasync_agent.this]
}

################################################################################
# AWS DataSync Location - FSx for NetApp ONTAP
################################################################################

resource "aws_datasync_location_fsx_ontap_file_system" "this" {
  for_each = var.fsx_ontap_locations

  storage_virtual_machine_arn = each.value.storage_virtual_machine_arn
  security_group_arns         = each.value.security_group_arns
  subdirectory                = each.value.subdirectory

  protocol {
    dynamic "nfs" {
      for_each = each.value.protocol.nfs != null ? [each.value.protocol.nfs] : []
      content {
        dynamic "mount_options" {
          for_each = nfs.value.mount_options != null ? [nfs.value.mount_options] : []
          content {
            version = mount_options.value.version
          }
        }
      }
    }

    dynamic "smb" {
      for_each = each.value.protocol.smb != null ? [each.value.protocol.smb] : []
      content {
        domain   = smb.value.domain
        password = smb.value.password
        user     = smb.value.user

        dynamic "mount_options" {
          for_each = smb.value.mount_options != null ? [smb.value.mount_options] : []
          content {
            version = mount_options.value.version
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - FSx for OpenZFS
################################################################################

resource "aws_datasync_location_fsx_openzfs_file_system" "this" {
  for_each = var.fsx_openzfs_locations

  fsx_filesystem_arn  = each.value.fsx_filesystem_arn
  security_group_arns = each.value.security_group_arns
  subdirectory        = each.value.subdirectory

  protocol {
    nfs {
      dynamic "mount_options" {
        for_each = each.value.protocol.nfs.mount_options != null ? [each.value.protocol.nfs.mount_options] : []
        content {
          version = mount_options.value.version
        }
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - FSx for Windows File Server
################################################################################

resource "aws_datasync_location_fsx_windows_file_system" "this" {
  for_each = var.fsx_windows_locations

  fsx_filesystem_arn  = each.value.fsx_filesystem_arn
  security_group_arns = each.value.security_group_arns
  user                = each.value.user
  password            = each.value.password
  domain              = each.value.domain
  subdirectory        = each.value.subdirectory

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - FSx for Lustre
################################################################################

resource "aws_datasync_location_fsx_lustre_file_system" "this" {
  for_each = var.fsx_lustre_locations

  fsx_filesystem_arn  = each.value.fsx_filesystem_arn
  security_group_arns = each.value.security_group_arns
  subdirectory        = each.value.subdirectory

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

################################################################################
# AWS DataSync Location - Object Storage
################################################################################

resource "aws_datasync_location_object_storage" "this" {
  for_each = var.object_storage_locations

  server_hostname = each.value.server_hostname
  bucket_name     = each.value.bucket_name
  subdirectory    = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"

  agent_arns = length(coalesce(each.value.agent_arns, [])) > 0 ? each.value.agent_arns : [
    for agent_key in coalesce(each.value.agent_keys, []) : aws_datasync_agent.this[agent_key].arn
  ]

  access_key      = each.value.access_key
  secret_key      = each.value.secret_key
  server_protocol = each.value.server_protocol
  server_port     = each.value.server_port

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [aws_datasync_agent.this]
}

################################################################################
# AWS DataSync Location - Azure Blob Storage
################################################################################

resource "aws_datasync_location_azure_blob" "this" {
  for_each = var.azure_blob_locations

  container_url       = each.value.container_url
  authentication_type = coalesce(each.value.authentication_type, "SAS")
  access_tier         = each.value.access_tier
  subdirectory        = each.value.subdirectory

  agent_arns = length(coalesce(each.value.agent_arns, [])) > 0 ? each.value.agent_arns : [
    for agent_key in coalesce(each.value.agent_keys, []) : aws_datasync_agent.this[agent_key].arn
  ]

  dynamic "sas_configuration" {
    for_each = each.value.sas_configuration != null ? [each.value.sas_configuration] : []
    content {
      token = sas_configuration.value.token
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [aws_datasync_agent.this]
}

################################################################################
# AWS DataSync Location - HDFS
################################################################################

resource "aws_datasync_location_hdfs" "this" {
  for_each = var.hdfs_locations

  authentication_type = each.value.authentication_type
  subdirectory        = startswith(coalesce(each.value.subdirectory, "/"), "/") ? coalesce(each.value.subdirectory, "/") : "/${each.value.subdirectory}"

  agent_arns = length(coalesce(each.value.agent_arns, [])) > 0 ? each.value.agent_arns : [
    for agent_key in coalesce(each.value.agent_keys, []) : aws_datasync_agent.this[agent_key].arn
  ]

  dynamic "name_node" {
    for_each = each.value.name_nodes
    content {
      hostname = name_node.value.hostname
      port     = name_node.value.port
    }
  }

  block_size                = each.value.block_size
  replication_factor        = each.value.replication_factor
  simple_user               = each.value.simple_user
  kerberos_principal        = each.value.kerberos_principal
  kerberos_keytab           = each.value.kerberos_keytab
  kerberos_keytab_base64    = each.value.kerberos_keytab_base64
  kerberos_krb5_conf        = each.value.kerberos_krb5_conf
  kerberos_krb5_conf_base64 = each.value.kerberos_krb5_conf_base64
  kms_key_provider_uri      = each.value.kms_key_provider_uri

  dynamic "qop_configuration" {
    for_each = each.value.qop_configuration != null ? [each.value.qop_configuration] : []
    content {
      rpc_protection           = qop_configuration.value.rpc_protection
      data_transfer_protection = qop_configuration.value.data_transfer_protection
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [aws_datasync_agent.this]
}

################################################################################
# AWS DataSync Task
################################################################################

resource "aws_datasync_task" "this" {
  for_each = var.tasks

  name = coalesce(each.value.name, each.key)

  source_location_arn = coalesce(
    each.value.source_location_arn,
    try(local.all_location_arns[each.value.source_location_key], null)
  )

  destination_location_arn = coalesce(
    each.value.destination_location_arn,
    try(local.all_location_arns[each.value.destination_location_key], null)
  )

  cloudwatch_log_group_arn = each.value.cloudwatch_log_group_arn

  dynamic "options" {
    for_each = each.value.options != null ? [each.value.options] : []
    content {
      atime                          = options.value.atime
      bytes_per_second               = options.value.bytes_per_second
      gid                            = options.value.gid
      log_level                      = options.value.log_level
      mtime                          = options.value.mtime
      overwrite_mode                 = options.value.overwrite_mode
      posix_permissions              = options.value.posix_permissions
      preserve_deleted_files         = options.value.preserve_deleted_files
      preserve_devices               = options.value.preserve_devices
      security_descriptor_copy_flags = options.value.security_descriptor_copy_flags
      task_queueing                  = options.value.task_queueing
      transfer_mode                  = options.value.transfer_mode
      uid                            = options.value.uid
      verify_mode                    = options.value.verify_mode
    }
  }

  dynamic "schedule" {
    for_each = each.value.schedule != null ? [each.value.schedule] : []
    content {
      schedule_expression = schedule.value.schedule_expression
    }
  }

  dynamic "includes" {
    for_each = each.value.includes != null ? [each.value.includes] : []
    content {
      filter_type = includes.value.filter_type
      value       = includes.value.value
    }
  }

  dynamic "excludes" {
    for_each = each.value.excludes != null ? [each.value.excludes] : []
    content {
      filter_type = excludes.value.filter_type
      value       = excludes.value.value
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )

  depends_on = [
    aws_datasync_location_s3.this,
    aws_datasync_location_efs.this,
    aws_datasync_location_nfs.this,
    aws_datasync_location_smb.this,
    aws_datasync_location_fsx_ontap_file_system.this,
    aws_datasync_location_fsx_openzfs_file_system.this,
    aws_datasync_location_fsx_windows_file_system.this,
    aws_datasync_location_fsx_lustre_file_system.this,
    aws_datasync_location_object_storage.this,
    aws_datasync_location_azure_blob.this,
    aws_datasync_location_hdfs.this
  ]
}
