module "secrets" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/secret?ref=v0.8.15" # Update this path to your child module source
  for_each = var.secrets

  secret_id                    = each.value.secret_id
  description                  = each.value.description
  kms_key_id                   = each.value.kms_key_id
  recovery_window_in_days      = each.value.recovery_window_in_days
  tags                         = each.value.tags
  custom_replication           = each.value.custom_replication
  replica_regions              = each.value.replica_regions
  set_rotation                 = each.value.set_rotation
  rotation_lambda_arn          = each.value.rotation_lambda_arn
  rotation_period_days         = each.value.rotation_period_days
  rotation_duration            = each.value.rotation_duration
  rotation_schedule_expression = each.value.rotation_schedule_expression
}
