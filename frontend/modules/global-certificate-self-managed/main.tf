module "global_certificate_self_managed" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/global-certificate-self-managed?ref=v0.7.2"
  for_each = var.global_certificate_self_managed

  project_id      = var.project_id
  name            = each.value.name
  description     = each.value.description
  pem_certificate = each.value.pem_certificate
  pem_private_key = each.value.pem_private_key
}
