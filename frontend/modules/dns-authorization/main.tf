module "dns_authorization" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/dns-authorization?ref=v0.6.18"
  for_each = var.dns_authorization

  project_id  = var.project_id
  name        = each.value.name
  domain      = each.value.domain
  description = each.value.description
}
