module "ip_address" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/ip-address?ref=v0.6.8"
  for_each = var.ip_address

  project_id   = var.project_id
  name         = each.value.name
  region       = each.value.region
  network_tier = each.value.network_tier
  description  = each.value.description
  labels       = each.value.labels
}
