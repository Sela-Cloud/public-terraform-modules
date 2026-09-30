################################################################################
# AWS Elastic IP (EIP) Resource
################################################################################

resource "aws_eip" "this" {
  domain                    = var.domain
  instance                  = var.instance
  network_interface         = var.network_interface
  associate_with_private_ip = var.associate_with_private_ip
  public_ipv4_pool          = var.public_ipv4_pool
  network_border_group      = var.network_border_group
  customer_owned_ipv4_pool  = var.customer_owned_ipv4_pool
  ipam_pool_id              = var.ipam_pool_id
  address                   = var.address

  timeouts {
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    precondition {
      condition     = !(var.instance != null && var.network_interface != null)
      error_message = "Only one of 'instance' or 'network_interface' can be specified, not both."
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

