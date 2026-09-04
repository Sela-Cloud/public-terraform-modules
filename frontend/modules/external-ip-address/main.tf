module "external_ip_address" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/external-ip-address?ref=v0.6.20"
  for_each = var.external_ip_address

  project_id           = var.project_id
  name                 = each.value.name
  region               = each.value.region
  network_tier         = each.value.network_tier
  ip_version           = each.value.ip_version
  assign_automatically = each.value.assign_automatically
  address              = each.value.address
  description          = each.value.description
  labels               = each.value.labels
}
