module "cloud_router" {
  source               = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-router?ref=v0.3.6"
  for_each             = var.cloud_router
  project_id           = var.project_id
  name                 = each.value.name
  region               = each.value.region
  network              = each.value.network
  description          = each.value.description
  asn                  = each.value.asn
  advertise_mode       = each.value.advertise_mode
  advertised_groups    = each.value.advertised_groups
  advertised_ip_ranges = each.value.advertised_ip_ranges
  keepalive_interval   = each.value.keepalive_interval
  identifier_range     = each.value.identifier_range
}
