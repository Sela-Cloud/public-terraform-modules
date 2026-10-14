################################################################################
# Customer Gateway
################################################################################

resource "aws_customer_gateway" "this" {
  count = var.create_customer_gateway ? 1 : 0

  type             = "ipsec.1"
  ip_address       = var.customer_gateway_ip_address
  bgp_asn          = var.customer_gateway_bgp_asn
  bgp_asn_extended = var.customer_gateway_bgp_asn_extended
  certificate_arn  = var.customer_gateway_certificate_arn
  device_name      = var.customer_gateway_device_name

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-cgw"
    }
  )

  lifecycle {
    precondition {
      condition     = var.customer_gateway_bgp_asn == null || var.customer_gateway_bgp_asn_extended == null
      error_message = "customer_gateway_bgp_asn and customer_gateway_bgp_asn_extended are mutually exclusive."
    }
  }
}

locals {
  customer_gateway_id = var.create_customer_gateway ? aws_customer_gateway.this[0].id : var.customer_gateway_id
}

################################################################################
# VPN Connection
################################################################################

resource "aws_vpn_connection" "this" {
  customer_gateway_id = local.customer_gateway_id
  vpn_gateway_id      = var.vpn_gateway_id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = var.static_routes_only
  # AWS only accepts enable_acceleration alongside transit_gateway_id -- confirmed via the
  # provider's own error ("all of enable_acceleration,transit_gateway_id must be specified"), not
  # just the docs' "only valid when attached to a Transit Gateway" note.
  enable_acceleration = var.transit_gateway_id != null ? var.enable_acceleration : null

  local_ipv4_network_cidr  = var.local_ipv4_network_cidr
  local_ipv6_network_cidr  = var.local_ipv6_network_cidr
  remote_ipv4_network_cidr = var.remote_ipv4_network_cidr
  remote_ipv6_network_cidr = var.remote_ipv6_network_cidr

  outside_ip_address_type                 = var.outside_ip_address_type
  transport_transit_gateway_attachment_id = var.transport_transit_gateway_attachment_id
  tunnel_inside_ip_version                = var.tunnel_inside_ip_version
  tunnel_bandwidth                        = var.tunnel_bandwidth
  preshared_key_storage                   = var.preshared_key_storage

  tunnel1_inside_cidr                     = var.tunnel1.inside_cidr
  tunnel1_inside_ipv6_cidr                = var.tunnel1.inside_ipv6_cidr
  tunnel1_preshared_key                   = var.tunnel1.preshared_key
  tunnel1_dpd_timeout_action              = var.tunnel1.dpd_timeout_action
  tunnel1_dpd_timeout_seconds             = var.tunnel1.dpd_timeout_seconds
  tunnel1_ike_versions                    = var.tunnel1.ike_versions
  tunnel1_phase1_dh_group_numbers         = var.tunnel1.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms    = var.tunnel1.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms     = var.tunnel1.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds         = var.tunnel1.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers         = var.tunnel1.phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms    = var.tunnel1.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms     = var.tunnel1.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds         = var.tunnel1.phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage           = var.tunnel1.rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds       = var.tunnel1.rekey_margin_time_seconds
  tunnel1_replay_window_size              = var.tunnel1.replay_window_size
  tunnel1_startup_action                  = var.tunnel1.startup_action
  tunnel1_enable_tunnel_lifecycle_control = var.tunnel1.enable_tunnel_lifecycle_control

  tunnel2_inside_cidr                     = var.tunnel2.inside_cidr
  tunnel2_inside_ipv6_cidr                = var.tunnel2.inside_ipv6_cidr
  tunnel2_preshared_key                   = var.tunnel2.preshared_key
  tunnel2_dpd_timeout_action              = var.tunnel2.dpd_timeout_action
  tunnel2_dpd_timeout_seconds             = var.tunnel2.dpd_timeout_seconds
  tunnel2_ike_versions                    = var.tunnel2.ike_versions
  tunnel2_phase1_dh_group_numbers         = var.tunnel2.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms    = var.tunnel2.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms     = var.tunnel2.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds         = var.tunnel2.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers         = var.tunnel2.phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms    = var.tunnel2.phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms     = var.tunnel2.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds         = var.tunnel2.phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage           = var.tunnel2.rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds       = var.tunnel2.rekey_margin_time_seconds
  tunnel2_replay_window_size              = var.tunnel2.replay_window_size
  tunnel2_startup_action                  = var.tunnel2.startup_action
  tunnel2_enable_tunnel_lifecycle_control = var.tunnel2.enable_tunnel_lifecycle_control

  dynamic "tunnel1_log_options" {
    for_each = var.tunnel1.cloudwatch_log_options != null ? [var.tunnel1.cloudwatch_log_options] : []
    content {
      cloudwatch_log_options {
        log_enabled           = tunnel1_log_options.value.log_enabled
        log_group_arn         = tunnel1_log_options.value.log_group_arn
        log_output_format     = tunnel1_log_options.value.log_output_format
        bgp_log_enabled       = tunnel1_log_options.value.bgp_log_enabled
        bgp_log_group_arn     = tunnel1_log_options.value.bgp_log_group_arn
        bgp_log_output_format = tunnel1_log_options.value.bgp_log_output_format
      }
    }
  }

  dynamic "tunnel2_log_options" {
    for_each = var.tunnel2.cloudwatch_log_options != null ? [var.tunnel2.cloudwatch_log_options] : []
    content {
      cloudwatch_log_options {
        log_enabled           = tunnel2_log_options.value.log_enabled
        log_group_arn         = tunnel2_log_options.value.log_group_arn
        log_output_format     = tunnel2_log_options.value.log_output_format
        bgp_log_enabled       = tunnel2_log_options.value.bgp_log_enabled
        bgp_log_group_arn     = tunnel2_log_options.value.bgp_log_group_arn
        bgp_log_output_format = tunnel2_log_options.value.bgp_log_output_format
      }
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
      condition     = (var.vpn_gateway_id != null) != (var.transit_gateway_id != null)
      error_message = "Exactly one of vpn_gateway_id or transit_gateway_id must be set."
    }
    precondition {
      condition     = var.tunnel_bandwidth == null || (var.vpn_gateway_id == null && !var.enable_acceleration)
      error_message = "tunnel_bandwidth is not supported when vpn_gateway_id is set or when enable_acceleration is true."
    }
    precondition {
      condition     = var.outside_ip_address_type != "PrivateIpv4" || var.transport_transit_gateway_attachment_id != null
      error_message = "outside_ip_address_type = \"PrivateIpv4\" requires transport_transit_gateway_attachment_id."
    }
    precondition {
      condition     = var.create_customer_gateway || var.customer_gateway_id != null
      error_message = "customer_gateway_id is required when create_customer_gateway is false."
    }
    precondition {
      condition     = var.static_routes_only || length(var.routes) == 0
      error_message = "routes can only be set when static_routes_only is true -- with BGP dynamic routing, AWS determines routes automatically."
    }
  }
}

################################################################################
# Static Routes
################################################################################

resource "aws_vpn_connection_route" "this" {
  for_each = { for r in var.routes : r.key => r }

  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = each.value.destination_cidr_block
}
