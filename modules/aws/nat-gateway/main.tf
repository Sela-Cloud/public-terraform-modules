################################################################################
# AWS NAT Gateway Resource
################################################################################

resource "aws_nat_gateway" "this" {
  allocation_id                      = var.allocation_id
  connectivity_type                  = var.connectivity_type
  subnet_id                          = var.subnet_id
  vpc_id                             = var.vpc_id
  availability_mode                  = var.availability_mode
  private_ip                         = var.private_ip
  secondary_allocation_ids           = length(var.secondary_allocation_ids) > 0 ? var.secondary_allocation_ids : null
  secondary_private_ip_addresses     = length(var.secondary_private_ip_addresses) > 0 ? var.secondary_private_ip_addresses : null
  secondary_private_ip_address_count = var.secondary_private_ip_address_count

  dynamic "availability_zone_address" {
    for_each = var.availability_zone_address != null ? var.availability_zone_address : []
    content {
      allocation_ids       = availability_zone_address.value.allocation_ids
      availability_zone    = availability_zone_address.value.availability_zone
      availability_zone_id = availability_zone_address.value.availability_zone_id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
