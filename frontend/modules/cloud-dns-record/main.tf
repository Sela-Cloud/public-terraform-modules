locals {
  records_by_name_and_type = {
    for record in values(var.cloud_dns_record) :
    "${lower(trimsuffix(record.name, "."))}|${upper(record.type)}" => record
  }
}

module "cloud_dns_record" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-dns-record?ref=v0.5.1"
  for_each = local.records_by_name_and_type

  project_id   = var.project_id
  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}
