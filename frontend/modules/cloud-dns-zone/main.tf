module "cloud_dns_zone" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-dns-zone?ref=v0.5.1"
  for_each = var.cloud_dns_zone

  project_id       = var.project_id
  name             = each.value.name
  dns_name         = each.value.dns_name
  visibility       = each.value.visibility
  description      = try(trimspace(each.value.description), "") != "" ? each.value.description : null
  labels           = each.value.labels
  private_networks = each.value.private_networks
  enable_logging   = each.value.enable_logging
}
