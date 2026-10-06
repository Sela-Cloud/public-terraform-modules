################################################################################
# AWS DataSync Agents Outputs
################################################################################

output "agents" {
  description = "Map of created AWS DataSync agents with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_agent.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

################################################################################
# AWS DataSync Locations Outputs
################################################################################

output "s3_locations" {
  description = "Map of created S3 locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_s3.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "efs_locations" {
  description = "Map of created EFS locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_efs.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "nfs_locations" {
  description = "Map of created NFS locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_nfs.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "smb_locations" {
  description = "Map of created SMB locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_smb.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "fsx_ontap_locations" {
  description = "Map of created FSx for ONTAP locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_fsx_ontap_file_system.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "fsx_openzfs_locations" {
  description = "Map of created FSx for OpenZFS locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_fsx_openzfs_file_system.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "fsx_windows_locations" {
  description = "Map of created FSx for Windows locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_fsx_windows_file_system.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "fsx_lustre_locations" {
  description = "Map of created FSx for Lustre locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_fsx_lustre_file_system.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "object_storage_locations" {
  description = "Map of created Object Storage locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_object_storage.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "azure_blob_locations" {
  description = "Map of created Azure Blob locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_azure_blob.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "hdfs_locations" {
  description = "Map of created HDFS locations with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_location_hdfs.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}

output "all_locations" {
  description = "Map of all created location keys to their ARNs."
  value       = local.all_location_arns
}

################################################################################
# AWS DataSync Tasks Outputs
################################################################################

output "tasks" {
  description = "Map of created AWS DataSync tasks with their IDs and ARNs."
  value = {
    for k, v in aws_datasync_task.this : k => {
      id  = v.id
      arn = v.arn
    }
  }
}
