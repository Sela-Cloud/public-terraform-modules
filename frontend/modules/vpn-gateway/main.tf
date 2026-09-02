module "vpn_gateway" {
  source                  = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/vpn-gateway?ref=v0.7.2"
  for_each                = var.vpn_gateway
  project_id              = var.project_id
  name                    = each.value.name
  region                  = each.value.region
  network                 = each.value.network
  existing_static_ip_name = each.value.existing_static_ip_name
  description             = each.value.description
}
