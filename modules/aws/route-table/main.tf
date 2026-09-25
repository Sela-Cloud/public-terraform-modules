################################################################################
# AWS Route Table Resources and Associations
################################################################################

locals {
  # Flatten subnet associations across all route tables: "${rt_key}.${subnet_id}"
  subnet_associations = {
    for item in flatten([
      for rt_key, rt in var.route_tables : [
        for subnet in coalesce(rt.subnets, []) : {
          key             = "${rt_key}.${subnet}"
          route_table_key = rt_key
          subnet_id       = subnet
        }
      ]
      ]) : item.key => {
      route_table_key = item.route_table_key
      subnet_id       = item.subnet_id
    }
  }

  # Gateway associations for edge routing (e.g. Internet Gateway or Virtual Private Gateway)
  gateway_associations = {
    for rt_key, rt in var.route_tables :
    rt_key => {
      route_table_key = rt_key
      gateway_id      = rt.gateway_id
    }
    if rt.gateway_id != null && rt.gateway_id != ""
  }
}

resource "aws_route_table" "this" {
  for_each = var.route_tables

  vpc_id           = coalesce(each.value.vpc_id, var.vpc_id)
  propagating_vgws = each.value.propagating_vgws

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = coalesce(each.value.name, each.key)
    }
  )
}

resource "aws_route_table_association" "subnet" {
  for_each = local.subnet_associations

  route_table_id = aws_route_table.this[each.value.route_table_key].id
  subnet_id      = each.value.subnet_id
}

resource "aws_route_table_association" "gateway" {
  for_each = local.gateway_associations

  route_table_id = aws_route_table.this[each.value.route_table_key].id
  gateway_id     = each.value.gateway_id
}
