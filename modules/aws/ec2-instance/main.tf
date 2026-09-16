################################################################################
# Fallback AMI Data Source
################################################################################

data "aws_ami" "amazon_linux_2023" {
  count       = var.ami == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  ami_id = coalesce(var.ami, try(data.aws_ami.amazon_linux_2023[0].id, null))
}

################################################################################
# AWS EC2 Instance
################################################################################

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : null
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  secondary_private_ips       = length(var.secondary_private_ips) > 0 ? var.secondary_private_ips : null
  source_dest_check           = var.source_dest_check
  availability_zone           = var.availability_zone
  placement_group             = var.placement_group
  tenancy                     = var.tenancy
  host_id                     = var.host_id

  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null || var.threads_per_core != null ? [1] : []
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.threads_per_core
    }
  }

  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  iam_instance_profile = var.iam_instance_profile
  monitoring           = var.monitoring
  ebs_optimized        = var.ebs_optimized

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_type           = root_block_device.value.volume_type
      volume_size           = root_block_device.value.volume_size
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      kms_key_id            = root_block_device.value.kms_key_id
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "credit_specification" {
    for_each = var.cpu_credits != null ? [var.cpu_credits] : []
    content {
      cpu_credits = credit_specification.value
    }
  }

  dynamic "maintenance_options" {
    for_each = var.auto_recovery != null ? [var.auto_recovery] : []
    content {
      auto_recovery = maintenance_options.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  volume_tags = merge(
    var.tags,
    var.volume_tags,
    {
      Name = var.name
    }
  )
}

################################################################################
# Additional EBS Volume Attachments
################################################################################

resource "aws_ebs_volume" "this" {
  for_each = { for disk in var.ebs_block_device : disk.device_name => disk }

  availability_zone = coalesce(var.availability_zone, aws_instance.this.availability_zone)
  size              = each.value.volume_size
  type              = each.value.volume_type
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id
  iops              = each.value.iops
  throughput        = each.value.throughput
  snapshot_id       = each.value.snapshot_id

  tags = merge(
    var.tags,
    var.volume_tags,
    each.value.tags,
    {
      Name = "${var.name}-disk-${replace(replace(each.key, "/dev/", ""), "/", "-")}"
    }
  )
}

resource "aws_volume_attachment" "this" {
  for_each = { for disk in var.ebs_block_device : disk.device_name => disk }

  device_name = each.key
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this.id
}

################################################################################
# Elastic IP (EIP)
################################################################################

resource "aws_eip" "this" {
  count  = var.enable_eip ? 1 : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    var.eip_tags,
    {
      Name = "${var.name}-eip"
    }
  )
}

resource "aws_eip_association" "this" {
  count         = var.enable_eip ? 1 : 0
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this[0].id
}
