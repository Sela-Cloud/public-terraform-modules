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

  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

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

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      availability_zone = placement.value.availability_zone
      affinity          = placement.value.affinity
      group_name        = placement.value.group_name
      host_id           = placement.value.host_id
      tenancy           = placement.value.tenancy
    }
  }

  dynamic "cpu_options" {
    for_each = var.cpu_options != null ? [var.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []
        content {
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )

  lifecycle {
    precondition {
      condition     = var.name == null || var.name_prefix == null
      error_message = "Set only one of name or name_prefix, not both."
    }
  }
}
