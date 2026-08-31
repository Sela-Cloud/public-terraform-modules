module "ip_address" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/ip-address?ref=v0.6.10"
  for_each = var.ip_address

  project_id           = var.project_id
  name                 = each.value.name
  type                 = each.value.type
  region               = each.value.region
  address_type         = each.value.address_type
  network              = each.value.network
  subnetwork           = each.value.subnetwork
  purpose              = each.value.purpose
  assign_automatically = each.value.assign_automatically
  address              = each.value.address
  ip_version           = each.value.ip_version
  network_tier         = each.value.network_tier
  description          = each.value.description
  labels               = each.value.labels
}
