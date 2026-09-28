################################################################################
# Trusted Entity -> Assume Role Policy
################################################################################

locals {
  # null unless trusted_entity_type is set, in which case it takes over from the raw
  # assume_role_policy entirely. The three branches build the same Statement shape as the module's
  # own default JSON (one Allow, one Action, one Principal) -- just with the Principal computed
  # instead of hand-written, and an optional ExternalId condition for the cross-account case.
  trusted_entity_principal = (
    var.trusted_entity_type == "AWS_SERVICE" ? { Service = var.trusted_service_principals } :
    var.trusted_entity_type == "AWS_ACCOUNT" ? { AWS = [for id in var.trusted_account_ids : "arn:aws:iam::${id}:root"] } :
    var.trusted_entity_type == "IAM_PRINCIPAL" ? { AWS = concat(var.trusted_role_arns, var.trusted_user_arns) } :
    null
  )

  generated_assume_role_policy = local.trusted_entity_principal == null ? null : jsonencode({
    Version = "2012-10-17"
    Statement = [merge(
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = local.trusted_entity_principal
      },
      var.trusted_external_id == null ? {} : {
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.trusted_external_id
          }
        }
      }
    )]
  })
}

################################################################################
# AWS IAM Role Resource
################################################################################

resource "aws_iam_role" "this" {
  name                  = var.name_prefix == null ? var.name : null
  name_prefix           = var.name_prefix
  assume_role_policy    = coalesce(local.generated_assume_role_policy, var.assume_role_policy)
  description           = var.description
  path                  = var.path
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary
  managed_policy_arns   = var.managed_policy_arns

  dynamic "inline_policy" {
    for_each = var.inline_policy
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy
    }
  }

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )

  lifecycle {
    precondition {
      condition     = var.trusted_entity_type != "AWS_SERVICE" || length(var.trusted_service_principals) > 0
      error_message = "trusted_service_principals is required when trusted_entity_type is AWS_SERVICE."
    }
    precondition {
      condition     = var.trusted_entity_type != "AWS_ACCOUNT" || length(var.trusted_account_ids) > 0
      error_message = "trusted_account_ids is required when trusted_entity_type is AWS_ACCOUNT."
    }
    precondition {
      condition     = var.trusted_entity_type != "IAM_PRINCIPAL" || (length(var.trusted_role_arns) > 0 || length(var.trusted_user_arns) > 0)
      error_message = "At least one of trusted_role_arns or trusted_user_arns is required when trusted_entity_type is IAM_PRINCIPAL."
    }
    precondition {
      condition     = contains(["AWS_SERVICE", "AWS_ACCOUNT", "IAM_PRINCIPAL"], coalesce(var.trusted_entity_type, "")) || var.assume_role_policy != null
      error_message = "assume_role_policy is required when trusted_entity_type is null or CUSTOM_JSON."
    }
  }
}
