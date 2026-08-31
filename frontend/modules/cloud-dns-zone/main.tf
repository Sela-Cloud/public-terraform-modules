module "cloud_dns_zone" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-dns-zone?ref=v0.6.10"
  for_each = var.cloud_dns_zone

  project_id               = var.project_id
  name                     = each.value.name
  dns_name                 = each.value.dns_name
  visibility               = each.value.visibility
  description              = try(trimspace(each.value.description), "") != "" ? each.value.description : null
  labels                   = each.value.labels
  private_networks         = each.value.private_networks
  zone_type                = each.value.zone_type
  forwarding_targets       = each.value.forwarding_targets
  peering_target_project   = try(trimspace(each.value.peering_target_project), "") != "" ? each.value.peering_target_project : null
  peering_target_network   = try(trimspace(each.value.peering_target_network), "") != "" ? each.value.peering_target_network : null
  dnssec_state             = each.value.dnssec_state
  dnssec_non_existence     = try(trimspace(each.value.dnssec_non_existence), "") != "" ? each.value.dnssec_non_existence : null
  dnssec_default_key_specs = each.value.dnssec_default_key_specs
  enable_logging           = each.value.enable_logging
}
