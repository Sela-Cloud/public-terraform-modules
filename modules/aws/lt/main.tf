################################################################################
# AWS Launch Template Resource
################################################################################

resource "aws_launch_template" "this" {
  name                   = var.name_prefix == null ? var.name : null
  name_prefix            = var.name_prefix
  description            = var.description
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data != null ? (can(base64decode(var.user_data)) ? var.user_data : base64encode(var.user_data)) : null
  ebs_optimized          = var.ebs_optimized
  vpc_security_group_ids = var.vpc_security_group_ids
  update_default_version = var.update_default_version

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null || var.iam_instance_profile_arn != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
      arn  = var.iam_instance_profile_arn
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
          iops                  = ebs.value.iops
          throughput            = ebs.value.throughput
          encrypted             = ebs.value.encrypted
          kms_key_id            = ebs.value.kms_key_id
          delete_on_termination = ebs.value.delete_on_termination
          snapshot_id           = ebs.value.snapshot_id
        }
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      delete_on_termination       = network_interfaces.value.delete_on_termination
      description                 = network_interfaces.value.description
      device_index                = network_interfaces.value.device_index
      security_groups             = network_interfaces.value.security_groups
      subnet_id                   = network_interfaces.value.subnet_id
    }
  }

  dynamic "metadata_options" {
    for_each = var.enable_metadata_options ? [1] : []
    content {
      http_endpoint               = var.http_endpoint
      http_tokens                 = var.http_tokens
      http_put_response_hop_limit = var.http_put_response_hop_limit
      instance_metadata_tags      = var.instance_metadata_tags
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring != null ? [1] : []
    content {
      enabled = var.enable_monitoring
    }
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )
}
