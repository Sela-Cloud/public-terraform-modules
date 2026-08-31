module "private_service_access" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/private-service-access?ref=v0.6.12"
  for_each = var.private_service_access

  project_id    = var.project_id
  name          = each.value.name
  network       = each.value.network
  prefix_length = each.value.prefix_length
  address       = try(trimspace(each.value.address), "") != "" ? each.value.address : null
}
