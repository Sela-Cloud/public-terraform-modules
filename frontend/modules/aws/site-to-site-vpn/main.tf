/******************************************
  AWS Site-to-Site VPN Root Module
 *****************************************/

module "site_to_site_vpn" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/site-to-site-vpn?ref=v0.9.12"
  for_each = var.site_to_site_vpn

  name = coalesce(each.value.name, each.key)

  create_customer_gateway           = each.value.create_customer_gateway
  customer_gateway_id               = each.value.customer_gateway_id
  customer_gateway_ip_address       = each.value.customer_gateway_ip_address
  customer_gateway_bgp_asn          = each.value.customer_gateway_bgp_asn
  customer_gateway_bgp_asn_extended = each.value.customer_gateway_bgp_asn_extended
  customer_gateway_certificate_arn  = each.value.customer_gateway_certificate_arn
  customer_gateway_device_name      = each.value.customer_gateway_device_name

  vpn_gateway_id     = each.value.vpn_gateway_id
  transit_gateway_id = each.value.transit_gateway_id

  static_routes_only                      = each.value.static_routes_only
  enable_acceleration                     = each.value.enable_acceleration
  local_ipv4_network_cidr                 = each.value.local_ipv4_network_cidr
  local_ipv6_network_cidr                 = each.value.local_ipv6_network_cidr
  remote_ipv4_network_cidr                = each.value.remote_ipv4_network_cidr
  remote_ipv6_network_cidr                = each.value.remote_ipv6_network_cidr
  outside_ip_address_type                 = each.value.outside_ip_address_type
  transport_transit_gateway_attachment_id = each.value.transport_transit_gateway_attachment_id
  tunnel_inside_ip_version                = each.value.tunnel_inside_ip_version
  tunnel_bandwidth                        = each.value.tunnel_bandwidth
  preshared_key_storage                   = each.value.preshared_key_storage

  tunnel1 = each.value.tunnel1
  tunnel2 = each.value.tunnel2

  routes = each.value.routes

  tags = each.value.tags
}
