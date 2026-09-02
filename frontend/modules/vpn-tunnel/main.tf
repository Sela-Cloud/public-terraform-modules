module "vpn_tunnel" {
  source                  = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/vpn-tunnel?ref=v0.7.2"
  for_each                = var.vpn_tunnel
  project_id              = var.project_id
  name                    = each.value.name
  region                  = each.value.region
  network                 = each.value.network
  gateway_name            = each.value.gateway_name
  peer_ip                 = each.value.peer_ip
  shared_secret           = each.value.shared_secret
  ike_version             = each.value.ike_version
  routing_mode            = each.value.routing_mode
  destination_ranges      = each.value.destination_ranges
  local_traffic_selector  = each.value.local_traffic_selector
  remote_traffic_selector = each.value.remote_traffic_selector
  description             = each.value.description
}
