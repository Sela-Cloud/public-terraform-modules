################################################################################
# AWS EBS Volume Resource
################################################################################

resource "aws_ebs_volume" "this" {
  availability_zone    = var.availability_zone
  size                 = var.size
  type                 = var.type
  iops                 = var.iops
  throughput           = var.throughput
  encrypted            = var.encrypted
  kms_key_id           = var.kms_key_id
  snapshot_id          = var.snapshot_id
  multi_attach_enabled = var.multi_attach_enabled
  final_snapshot       = var.final_snapshot

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
