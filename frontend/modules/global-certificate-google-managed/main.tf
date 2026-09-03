module "global_certificate_google_managed" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/global-certificate-google-managed?ref=v0.6.19"
  for_each = var.global_certificate_google_managed

  project_id              = var.project_id
  name                    = each.value.name
  description             = each.value.description
  domain_names            = each.value.domain_names
  authorization_type      = each.value.authorization_type
  dns_authorization_names = each.value.dns_authorization_names
}
