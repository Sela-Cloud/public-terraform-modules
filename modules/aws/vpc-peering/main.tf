################################################################################
# AWS VPC Peering Connection Resource
################################################################################

resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  auto_accept   = var.auto_accept

  dynamic "requester" {
    for_each = var.allow_remote_vpc_dns_resolution ? [1] : []
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
