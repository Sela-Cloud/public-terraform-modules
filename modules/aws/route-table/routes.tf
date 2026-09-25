################################################################################
# AWS Route Resources
################################################################################

locals {
  # Flatten routes across all route tables into a map with composite stable keys: "${rt_key}.${route_key}"
  routes = {
    for item in flatten([
      for rt_key, rt in var.route_tables : [
        for r_key, r in coalesce(rt.routes, {}) : merge(r, {
          key             = "${rt_key}.${r_key}"
          route_table_key = rt_key
        })
      ]
    ]) : item.key => item
  }
}

resource "aws_route" "this" {
  for_each = local.routes

  route_table_id = aws_route_table.this[each.value.route_table_key].id

  # Destination attributes (mutually exclusive)
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block
  destination_prefix_list_id  = each.value.destination_prefix_list_id

  # Target attributes (mutually exclusive)
  carrier_gateway_id        = each.value.carrier_gateway_id
  core_network_arn          = each.value.core_network_arn
  egress_only_gateway_id    = each.value.egress_only_gateway_id
  gateway_id                = each.value.gateway_id
  local_gateway_id          = each.value.local_gateway_id
  nat_gateway_id            = each.value.nat_gateway_id
  network_interface_id      = each.value.network_interface_id
  transit_gateway_id        = each.value.transit_gateway_id
  vpc_endpoint_id           = each.value.vpc_endpoint_id
  vpc_peering_connection_id = each.value.vpc_peering_connection_id

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}
