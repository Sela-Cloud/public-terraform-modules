module "function_app_function" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/function-app-function?ref=v0.7.6"
  for_each = var.function_app_function

  name            = each.value.name
  function_app_id = each.value.function_app_id
  config_json     = each.value.config_json
  enabled         = each.value.enabled
  language        = each.value.language
  files           = each.value.files
  test_data       = each.value.test_data
}
