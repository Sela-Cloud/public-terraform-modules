locals {
  load_balancers = {
    for key, lb in var.regional_internal_lb : key => merge(lb, {
      backend_services = { for s in lb.backend_services : s.service_name => s }
      domains = {
        for d in lb.domains : d.matcher_key => {
          hosts           = d.hosts
          default_service = d.default_service
          route_rules     = d.route_rules
        }
      }
    })
  }
}

module "regional_internal_lb" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gcp/regional-internal-lb?ref=v0.9.0"
  for_each = local.load_balancers

  project_id            = var.project_id
  backend_project_id    = try(trimspace(each.value.backend_project_id), "") != "" ? each.value.backend_project_id : null
  name                  = each.value.name
  region                = each.value.region
  network               = each.value.network
  subnetwork            = each.value.subnetwork
  existing_address_name = try(trimspace(each.value.existing_address_name), "") != "" ? each.value.existing_address_name : null
  address               = try(trimspace(each.value.address), "") != "" ? each.value.address : null
  certificate_names     = each.value.certificate_names
  create_http_redirect  = each.value.create_http_redirect
  allow_global_access   = each.value.allow_global_access
  labels                = each.value.labels
  default_service       = each.value.default_service
  backend_services      = each.value.backend_services
  domains               = each.value.domains
}
