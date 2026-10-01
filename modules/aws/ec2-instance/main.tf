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
  ami_id             = coalesce(var.ami, try(data.aws_ami.amazon_linux_2023[0].id, null))
  key_name           = try(aws_key_pair.this[0].key_name, var.key_name)
  security_group_ids = compact(concat(
    var.vpc_security_group_ids,
    try([aws_security_group.this[0].id], [])
  ))
}

################################################################################
# SSH Key Pair
################################################################################

resource "tls_private_key" "this" {
  count     = var.create_key_pair && var.generate_ssh_key && var.public_key == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = coalesce(var.key_pair_name, "${var.name}-key")
  public_key = coalesce(var.public_key, try(tls_private_key.this[0].public_key_openssh, null))

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.key_pair_name, "${var.name}-key")
    }
  )
}

################################################################################
# Dedicated Security Group for SSH
################################################################################

resource "aws_security_group" "this" {
  count       = var.create_security_group && var.vpc_id != null ? 1 : 0
  name        = coalesce(var.security_group_name, "${var.name}-sg")
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    var.security_group_tags,
    {
      Name = coalesce(var.security_group_name, "${var.name}-sg")
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = var.create_security_group && var.vpc_id != null ? toset(var.ssh_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id
  description       = "Allow inbound SSH access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create_security_group && var.vpc_id != null ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

################################################################################
# AWS EC2 Instance
################################################################################

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  key_name                    = local.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = length(local.security_group_ids) > 0 ? local.security_group_ids : null
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

  dynamic "enclave_options" {
    for_each = var.enable_enclave != null ? [1] : []
    content {
      enabled = var.enable_enclave
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.private_dns_name_options != null ? [var.private_dns_name_options] : []
    content {
      hostname_type                        = private_dns_name_options.value.hostname_type
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification != null ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []
        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = ephemeral_block_device.value.virtual_name
      no_device    = ephemeral_block_device.value.no_device
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
