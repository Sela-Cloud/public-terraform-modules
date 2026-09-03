module "iam_custom_role" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/custom-role?ref=v0.6.19"
  for_each = var.iam_custom_role

  project     = var.project_id
  role_id     = each.value.role_id
  permissions = each.value.permissions
}
