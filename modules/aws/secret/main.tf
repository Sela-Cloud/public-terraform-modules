resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_id
  description             = var.description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags

  # AWS handles multi-region replication natively inside the secret block
  dynamic "replica" {
    for_each = var.custom_replication ? var.replica_regions : []
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  lifecycle {
    precondition {
      condition     = var.custom_replication || length(var.replica_regions) == 0
      error_message = "replica_regions is only used when custom_replication is true."
    }
    precondition {
      condition     = !var.custom_replication || length(var.replica_regions) > 0
      error_message = "At least one replica region configuration is required when custom_replication is true."
    }
  }
}

# AWS handles rotation via a separate dedicated configuration block
resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.set_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_period_days
    duration                 = var.rotation_duration
    schedule_expression      = var.rotation_schedule_expression
  }

  lifecycle {
    precondition {
      condition     = var.rotation_lambda_arn != null
      error_message = "rotation_lambda_arn must be provided to enable AWS Secrets Manager secret rotation."
    }
    precondition {
      condition     = !(var.rotation_period_days != null && var.rotation_schedule_expression != null)
      error_message = "Set only one of rotation_period_days or rotation_schedule_expression, not both."
    }
  }
}
