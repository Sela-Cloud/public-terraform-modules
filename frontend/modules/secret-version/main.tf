module "secret_version" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/secret-version?ref=v0.7.1"
  for_each = var.secret_version

  project_id  = var.project_id
  secret_name = each.value.secret_name
  secret_data = each.value.secret_data
  enabled     = each.value.enabled
}
