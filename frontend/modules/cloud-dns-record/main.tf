locals {
  records_by_name_and_type = {
    for record in values(var.cloud_dns_record) :
    "${lower(trimsuffix(record.name, "."))}|${upper(record.type)}" => record
  }
}

module "cloud_dns_record" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-dns-record?ref=v0.5.4"
  for_each = local.records_by_name_and_type

  project_id           = var.project_id
  managed_zone         = each.value.managed_zone
  name                 = each.value.name
  type                 = each.value.type
  ttl                  = each.value.ttl
  rrdatas              = each.value.rrdatas
  routing_policy_type  = each.value.routing_policy_type
  dnssec_enabled       = each.value.dnssec_enabled
  routing_health_check = try(trimspace(each.value.routing_health_check), "") != "" ? each.value.routing_health_check : null
  wrr_targets          = each.value.wrr_targets
  geo_targets          = each.value.geo_targets
}
