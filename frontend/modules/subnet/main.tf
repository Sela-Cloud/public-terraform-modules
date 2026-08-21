module "subnet" {
  source                         = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/subnet?ref=v0.5.10"
  for_each                       = var.subnet
  project_id                     = var.project_id
  name                           = each.value.name
  region                         = each.value.region
  network                        = each.value.network
  ip_cidr_range                  = each.value.ip_cidr_range
  description                    = each.value.description
  purpose                        = each.value.purpose
  role                           = each.value.role
  private_ip_google_access       = each.value.private_ip_google_access
  stack_type                     = each.value.stack_type
  ipv6_access_type               = each.value.ipv6_access_type
  reserved_internal_range        = each.value.reserved_internal_range
  flow_logs                      = each.value.flow_logs
  flow_logs_aggregation_interval = each.value.flow_logs_aggregation_interval
  flow_logs_sampling             = each.value.flow_logs_sampling
  flow_logs_metadata             = each.value.flow_logs_metadata
  secondary_ip_ranges            = each.value.secondary_ip_ranges

  # Not user-configurable. These three inputs are required by the pinned remote
  # module (v0.5.4 declares them without defaults), but no form control sets
  # them, so they were unreachable object attributes. They are now pinned to the
  # values the removed optional() defaults produced, which keeps existing
  # deployments byte-identical.
  private_ipv6_google_access = null
  flow_logs_metadata_fields  = []
  flow_logs_filter_expr      = "true"
}
