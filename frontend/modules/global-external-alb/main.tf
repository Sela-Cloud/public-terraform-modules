locals {
  load_balancers = {
    for key, alb in var.global_external_alb : key => merge(alb, {
      backend_buckets  = { for b in alb.backend_buckets : b.bucket_name => b }
      backend_services = { for s in alb.backend_services : s.service_name => s }
      domains = {
        for d in alb.domains : d.matcher_key => {
          hosts           = d.hosts
          default_service = d.default_service
          route_rules     = d.route_rules
        }
      }
    })
  }
}

module "global_external_alb" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/global-external-alb?ref=v0.6.0"
  for_each = local.load_balancers

  project_id              = var.project_id
  backend_project_id      = try(trimspace(each.value.backend_project_id), "") != "" ? each.value.backend_project_id : null
  name                    = each.value.name
  existing_static_ip_name = try(trimspace(each.value.existing_static_ip_name), "") != "" ? each.value.existing_static_ip_name : null
  certificate_map_name    = each.value.certificate_map_name
  default_service         = each.value.default_service
  create_http_redirect    = each.value.create_http_redirect
  backend_buckets         = each.value.backend_buckets
  backend_services        = each.value.backend_services
  domains                 = each.value.domains
}
