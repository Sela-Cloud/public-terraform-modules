module "vpn" {
  source                  = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/vpn?ref=v0.3.4"
  for_each                = var.vpn
  project_id              = var.project_id
  name                    = each.value.name
  region                  = each.value.region
  network                 = each.value.network
  peer_ip                 = each.value.peer_ip
  shared_secret           = each.value.shared_secret
  ike_version             = each.value.ike_version
  local_traffic_selector  = each.value.local_traffic_selector
  remote_traffic_selector = each.value.remote_traffic_selector
  description             = each.value.description
}
