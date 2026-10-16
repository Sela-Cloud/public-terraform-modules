/******************************************
  AWS Lambda Root Module
 *****************************************/

module "lambda" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/lambda?ref=v0.9.20"
  for_each = var.lambda

  function_name                  = coalesce(each.value.function_name, each.key)
  description                    = each.value.description
  handler                        = each.value.handler
  runtime                        = each.value.runtime
  architectures                  = each.value.architectures
  memory_size                    = each.value.memory_size
  timeout                        = each.value.timeout
  reserved_concurrent_executions = each.value.reserved_concurrent_executions
  publish                        = each.value.publish
  kms_key_arn                    = each.value.kms_key_arn
  package_type                   = each.value.package_type
  code_signing_config_arn        = each.value.code_signing_config_arn

  replace_security_groups_on_destroy = each.value.replace_security_groups_on_destroy
  replacement_security_group_ids     = each.value.replacement_security_group_ids
  skip_destroy                       = each.value.skip_destroy

  filename                   = each.value.filename
  source_code_hash           = each.value.source_code_hash
  s3_bucket                  = each.value.s3_bucket
  s3_key                     = each.value.s3_key
  s3_object_version          = each.value.s3_object_version
  image_uri                  = each.value.image_uri
  create_placeholder_package = each.value.create_placeholder_package
  layers                     = each.value.layers

  environment_variables       = each.value.environment_variables
  vpc_subnet_ids              = each.value.vpc_subnet_ids
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  ipv6_allowed_for_dual_stack = each.value.ipv6_allowed_for_dual_stack
  dead_letter_target_arn      = each.value.dead_letter_target_arn
  tracing_mode                = each.value.tracing_mode
  ephemeral_storage_size      = each.value.ephemeral_storage_size
  file_system_config          = each.value.file_system_config
  image_config                = each.value.image_config
  logging_config              = each.value.logging_config
  snap_start                  = each.value.snap_start

  create_role              = each.value.create_role
  lambda_role_arn          = each.value.lambda_role_arn
  role_name                = each.value.role_name
  role_description         = each.value.role_description
  permissions_boundary     = each.value.permissions_boundary
  role_policy_arns         = each.value.role_policy_arns
  custom_policy_statements = each.value.custom_policy_statements != null ? jsondecode(each.value.custom_policy_statements) : []
  role_tags                = each.value.role_tags

  create_log_group      = each.value.create_log_group
  log_retention_in_days = each.value.log_retention_in_days
  log_group_kms_key_id  = each.value.log_group_kms_key_id
  log_group_class       = each.value.log_group_class

  create_function_url      = each.value.create_function_url
  function_url_auth_type   = each.value.function_url_auth_type
  function_url_invoke_mode = each.value.function_url_invoke_mode
  function_url_qualifier   = each.value.function_url_qualifier
  function_url_cors        = each.value.function_url_cors

  lambda_permissions    = { for p in each.value.lambda_permissions : p.key => p }
  aliases               = { for a in each.value.aliases : a.key => a }
  event_source_mappings = { for e in each.value.event_source_mappings : e.key => e }

  provisioned_concurrency_config = each.value.provisioned_concurrency_config

  layers_to_create = { for l in each.value.layers_to_create : l.key => l }

  code_signing_config = each.value.code_signing_config

  tags = each.value.tags
}
