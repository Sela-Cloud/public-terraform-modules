################################################################################
# Current AWS Context & Data Sources
################################################################################

data "aws_region" "current" {}

data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

locals {
  current_region = data.aws_region.current.region
  effective_vpc_id = coalesce(var.vpc_id, try(data.aws_vpc.default[0].id, null))

  effective_security_group_ids = compact(concat(
    var.security_group_ids,
    try([aws_security_group.this[0].id], [])
  ))
}

################################################################################
# Dedicated Security Group for Interface Endpoints
################################################################################

resource "aws_security_group" "this" {
  count       = var.create_security_group && local.effective_vpc_id != null ? 1 : 0
  name        = coalesce(var.security_group_name, "vpc-endpoints-sg")
  description = var.security_group_description
  vpc_id      = local.effective_vpc_id

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.security_group_name, "vpc-endpoints-sg")
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count = var.create_security_group && local.effective_vpc_id != null ? length(var.security_group_ingress_rules) : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = var.security_group_ingress_rules[count.index].description
  from_port                    = var.security_group_ingress_rules[count.index].from_port
  to_port                      = var.security_group_ingress_rules[count.index].to_port
  ip_protocol                  = var.security_group_ingress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.security_group_ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.security_group_ingress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.security_group_ingress_rules[count.index].referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  count = var.create_security_group && local.effective_vpc_id != null ? length(var.security_group_egress_rules) : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = var.security_group_egress_rules[count.index].description
  from_port                    = var.security_group_egress_rules[count.index].from_port
  to_port                      = var.security_group_egress_rules[count.index].to_port
  ip_protocol                  = var.security_group_egress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.security_group_egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.security_group_egress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.security_group_egress_rules[count.index].referenced_security_group_id
}

################################################################################
# VPC Endpoints
################################################################################

resource "aws_vpc_endpoint" "this" {
  for_each = var.endpoints

  vpc_id = local.effective_vpc_id

  service_name = coalesce(
    try(each.value.service_name, null),
    try(startswith(each.value.service, "com.amazonaws"), false) ? each.value.service : null,
    try(each.value.service, null) != null ? "com.amazonaws.${local.current_region}.${each.value.service}" : null,
    "com.amazonaws.${local.current_region}.${each.key}"
  )

  vpc_endpoint_type = coalesce(try(each.value.service_type, null), "Interface")

  # Subnets for Interface endpoints (mutually exclusive with subnet_configuration)
  subnet_ids = coalesce(try(each.value.service_type, null), "Interface") == "Interface" && length(try(each.value.subnet_configuration, [])) == 0 ? (
    try(each.value.subnet_ids, null) != null ? each.value.subnet_ids : (length(var.subnet_ids) > 0 ? var.subnet_ids : null)
  ) : null

  # Route Tables for Gateway endpoints
  route_table_ids = coalesce(try(each.value.service_type, null), "Interface") == "Gateway" ? (
    try(each.value.route_table_ids, null) != null ? each.value.route_table_ids : (length(var.route_table_ids) > 0 ? var.route_table_ids : null)
  ) : null

  # Security Groups for Interface endpoints
  security_group_ids = coalesce(try(each.value.service_type, null), "Interface") == "Interface" ? (
    try(each.value.security_group_ids, null) != null ? each.value.security_group_ids : (length(local.effective_security_group_ids) > 0 ? local.effective_security_group_ids : null)
  ) : null

  # Private DNS (only applicable to Interface endpoints)
  private_dns_enabled = coalesce(try(each.value.service_type, null), "Interface") == "Interface" ? (
    try(each.value.private_dns_enabled, null) != null ? each.value.private_dns_enabled : true
  ) : null

  auto_accept                = try(each.value.auto_accept, true)
  policy                     = try(each.value.policy, null)
  ip_address_type            = try(each.value.ip_address_type, null)
  service_region             = try(each.value.service_region, null)
  resource_configuration_arn = try(each.value.resource_configuration_arn, null)
  service_network_arn        = try(each.value.service_network_arn, null)

  dynamic "subnet_configuration" {
    for_each = try(each.value.subnet_configuration, null) != null ? each.value.subnet_configuration : []
    content {
      subnet_id = subnet_configuration.value.subnet_id
      ipv4      = try(subnet_configuration.value.ipv4, null)
      ipv6      = try(subnet_configuration.value.ipv6, null)
    }
  }

  dynamic "dns_options" {
    for_each = try(each.value.dns_options, null) != null ? [each.value.dns_options] : []
    content {
      dns_record_ip_type                             = try(dns_options.value.dns_record_ip_type, null)
      private_dns_only_for_inbound_resolver_endpoint = try(dns_options.value.private_dns_only_for_inbound_resolver_endpoint, null)
      private_dns_preference                         = try(dns_options.value.private_dns_preference, null)
      private_dns_specified_domains                  = try(dns_options.value.private_dns_specified_domains, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) != null ? [each.value.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${local.effective_vpc_id}-${each.key}-endpoint"
    }
  )
}
