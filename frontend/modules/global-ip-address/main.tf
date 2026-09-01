module "global_ip_address" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/global-ip-address?ref=v0.6.15"
  for_each = var.global_ip_address

  project_id           = var.project_id
  name                 = each.value.name
  ip_version           = each.value.ip_version
  assign_automatically = each.value.assign_automatically
  address              = each.value.address
  description          = each.value.description
  labels               = each.value.labels
}
