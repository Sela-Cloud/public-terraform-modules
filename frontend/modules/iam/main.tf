locals {
  custom_role_configs = {
    for key, config in var.iam_configs : key => config
    if config.custom_role_id != null
  }

  service_account_configs = {
    for key, config in var.iam_configs : key => config
    if config.service_account_name != "" || config.existing_service_account_email != ""
  }

  project_role_configs = {
    for key, config in var.iam_configs : key => config
    if length(config.project_level_roles) > 0
  }
}

module "custom_roles" {
  for_each    = local.custom_role_configs
  source      = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/custom-role?ref=v0.6.8"
  project     = var.project_id
  role_id     = each.value.custom_role_id
  permissions = each.value.custom_role_permissions
}

module "service_accounts" {
  for_each = local.service_account_configs

  source                         = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/service-account?ref=v0.6.8"
  project_id                     = var.project_id
  service_account_name           = each.value.service_account_name
  iam_members                    = each.value.iam_members
  existing_service_account_email = each.value.existing_service_account_email
}

module "member_roles" {
  for_each = local.project_role_configs

  source  = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/iam/member-iam?ref=v0.6.8"
  project = var.project_id

  service_account_address = try(module.service_accounts[each.key].email, null)
  user_email_address      = each.value.user_email_address
  project_roles           = each.value.project_level_roles
  depends_on              = [module.custom_roles, module.service_accounts]
}
