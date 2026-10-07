/******************************************
  AWS DataSync Root Module
 *****************************************/

module "datasync" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/datasync?ref=aws-wip"
  for_each = var.datasync

  agents                   = each.value.agents
  s3_locations             = each.value.s3_locations
  efs_locations            = each.value.efs_locations
  nfs_locations            = each.value.nfs_locations
  smb_locations            = each.value.smb_locations
  fsx_ontap_locations      = each.value.fsx_ontap_locations
  fsx_openzfs_locations    = each.value.fsx_openzfs_locations
  fsx_windows_locations    = each.value.fsx_windows_locations
  fsx_lustre_locations     = each.value.fsx_lustre_locations
  object_storage_locations = each.value.object_storage_locations
  azure_blob_locations     = each.value.azure_blob_locations
  hdfs_locations           = each.value.hdfs_locations
  tasks                    = each.value.tasks
  tags                     = each.value.tags
}
