module "iam_service_account" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/service-account?ref=v0.5.8"
  for_each = var.iam_service_account

  project_id           = var.project_id
  service_account_name = each.value.service_account_name
  iam_members          = each.value.iam_members
}
