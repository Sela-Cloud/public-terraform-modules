module "cloud_dns_record" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-dns-record?ref=v0.5.6"
  # Keyed directly by the tfvars map key so that the Terraform address of one record is
  # module.cloud_dns_record["<map key>"] and can be derived rather than declared (IMPORT_PLAN R10).
  # The previous local re-keyed by "name|type" via values(), which discarded the map key entirely
  # and made the address unreachable from the metadata. Uniqueness of name+type is now asserted in
  # variables.tf, where a collision fails loudly instead of one record silently overwriting another.
  for_each = var.cloud_dns_record

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
