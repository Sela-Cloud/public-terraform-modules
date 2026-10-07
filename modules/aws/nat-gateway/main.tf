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

  lifecycle {
    precondition {
      condition     = var.availability_mode != "zonal" || var.subnet_id != null
      error_message = "subnet_id is required when availability_mode is 'zonal'."
    }
    precondition {
      condition     = var.availability_mode != "zonal" || var.connectivity_type != "public" || var.allocation_id != null
      error_message = "allocation_id is required when availability_mode is 'zonal' and connectivity_type is 'public'."
    }
    precondition {
      condition     = var.availability_mode != "zonal" || var.vpc_id == null
      error_message = "vpc_id must not be set when availability_mode is 'zonal'."
    }
    precondition {
      condition     = var.availability_mode != "regional" || var.vpc_id != null
      error_message = "vpc_id is required when availability_mode is 'regional'."
    }
    precondition {
      condition     = var.availability_mode != "regional" || (var.subnet_id == null && var.allocation_id == null)
      error_message = "subnet_id and allocation_id must not be set when availability_mode is 'regional'."
    }
  }
}
