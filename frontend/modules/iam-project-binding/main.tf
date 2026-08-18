module "iam_project_binding" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/member-iam?ref=v0.5.7"
  for_each = var.iam_project_binding

  project                 = var.project_id
  project_roles           = [each.value.role]
  service_account_address = each.value.principal_type == "serviceAccount" ? each.value.service_account_email : null
  user_email_address      = each.value.principal_type == "user" ? each.value.user_email_address : null
  principal_set_address   = each.value.principal_type == "principalSet" ? each.value.principal_set_address : null
}
