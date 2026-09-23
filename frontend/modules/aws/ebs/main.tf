/******************************************
  AWS EBS Volume Root Module
 *****************************************/

module "ebs" {
  source   = "../../../../modules/aws/ebs"
  for_each = var.ebs

  name                 = coalesce(each.value.name, each.key)
  availability_zone    = each.value.availability_zone
  size                 = each.value.size
  type                 = each.value.type
  iops                 = each.value.iops
  throughput           = each.value.throughput
  encrypted            = each.value.encrypted
  kms_key_id           = each.value.kms_key_id
  snapshot_id          = each.value.snapshot_id
  multi_attach_enabled = each.value.multi_attach_enabled
  final_snapshot       = each.value.final_snapshot
  tags                 = each.value.tags
}
