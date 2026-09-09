module "internal_ip_address" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/internal-ip-address?ref=v0.7.0"
  for_each = var.internal_ip_address

  project_id           = var.project_id
  name                 = each.value.name
  region               = each.value.region
  network              = each.value.network
  subnetwork           = each.value.subnetwork
  purpose              = each.value.purpose
  assign_automatically = each.value.assign_automatically
  address              = each.value.address
  description          = each.value.description
  labels               = each.value.labels
}
