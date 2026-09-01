locals {
  certificate_maps = {
    for key, m in var.certificate_map : key => merge(m, {
      entries = { for e in m.entries : e.entry_name => e }
    })
  }
}

module "certificate_map" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/certificate-map?ref=v0.6.18"
  for_each = local.certificate_maps

  project_id  = var.project_id
  name        = each.value.name
  description = each.value.description
  entries = {
    for entry_key, e in each.value.entries : entry_key => {
      description  = e.description
      hostname     = e.hostname
      is_primary   = e.is_primary
      certificates = e.certificates
      labels       = e.labels
    }
  }
}
