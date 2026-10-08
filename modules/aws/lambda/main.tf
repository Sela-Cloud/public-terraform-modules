################################################################################
# Locals & Computed Properties
################################################################################

locals {
  # Determine if an automated placeholder zip should be used
  use_placeholder = var.create_placeholder_package && var.package_type == "Zip" && var.filename == null && var.s3_bucket == null && var.image_uri == null

  # Select execution role ARN (created role or user-provided role)
  role_arn = var.create_role ? aws_iam_role.this[0].arn : var.lambda_role_arn

  # Deployment package attributes
  filename         = local.use_placeholder ? data.archive_file.placeholder[0].output_path : var.filename
  source_code_hash = local.use_placeholder ? data.archive_file.placeholder[0].output_base64sha256 : var.source_code_hash

  # Code signing config ARN (created or provided)
  code_signing_config_arn = try(aws_lambda_code_signing_config.this[0].arn, var.code_signing_config_arn)

  # Check if VPC configuration is active
  has_vpc = length(var.vpc_subnet_ids) > 0 && length(var.vpc_security_group_ids) > 0

  # Combined layer ARNs (provided layers + layers created in this module)
  all_layers = distinct(concat(
    var.layers,
    [for layer in aws_lambda_layer_version.this : layer.arn]
  ))
}

################################################################################
# Automated Bootstrap / Placeholder Package
################################################################################

data "archive_file" "placeholder" {
  count       = local.use_placeholder ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/placeholder_package.zip"

  source {
    content  = "exports.handler = async (event) => {\n  return {\n    statusCode: 200,\n    headers: { 'Content-Type': 'application/json' },\n    body: JSON.stringify({ message: 'Hello from AWS Lambda!', event: event })\n  };\n};"
    filename = "index.js"
  }
}

################################################################################
# IAM Execution Role & Policies
################################################################################

data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name                 = coalesce(var.role_name, "${var.function_name}-role")
  description          = var.role_description
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json
  permissions_boundary = var.permissions_boundary

  tags = merge(
    var.tags,
    var.role_tags,
    {
      Name = coalesce(var.role_name, "${var.function_name}-role")
    }
  )
}

# Attach AWSLambdaBasicExecutionRole (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "basic" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWSLambdaVPCAccessExecutionRole if VPC enabled
resource "aws_iam_role_policy_attachment" "vpc" {
  count = var.create_role && local.has_vpc ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Attach user-supplied managed policy ARNs
resource "aws_iam_role_policy_attachment" "custom" {
  for_each = var.create_role ? toset(var.role_policy_arns) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# Attach custom inline policy if statements provided
resource "aws_iam_role_policy" "custom" {
  count = var.create_role && length(var.custom_policy_statements) > 0 ? 1 : 0

  name = "${var.function_name}-custom-policy"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.custom_policy_statements
  })
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_group_kms_key_id
  log_group_class   = var.log_group_class

  tags = merge(
    var.tags,
    {
      Name = "/aws/lambda/${var.function_name}"
    }
  )
}

################################################################################
# Code Signing Configuration
################################################################################

resource "aws_lambda_code_signing_config" "this" {
  count = var.code_signing_config != null ? 1 : 0

  description = var.code_signing_config.description

  allowed_publishers {
    signing_profile_version_arns = var.code_signing_config.signing_profile_version_arns
  }

  policies {
    untrusted_artifact_on_deployment = var.code_signing_config.untrusted_artifact_on_deployment
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.function_name}-code-signing-config"
    }
  )
}

################################################################################
# Lambda Layer Versions
################################################################################

resource "aws_lambda_layer_version" "this" {
  for_each = var.layers_to_create

  layer_name               = each.key
  filename                 = each.value.filename
  s3_bucket                = each.value.s3_bucket
  s3_key                   = each.value.s3_key
  s3_object_version        = each.value.s3_object_version
  compatible_runtimes      = each.value.compatible_runtimes
  compatible_architectures = each.value.compatible_architectures
  description              = each.value.description
  license_info             = each.value.license_info
  source_code_hash         = each.value.source_code_hash
  skip_destroy             = each.value.skip_destroy
}

################################################################################
# AWS Lambda Function
################################################################################

resource "aws_lambda_function" "this" {
  function_name                  = var.function_name
  description                    = var.description
  role                           = local.role_arn
  handler                        = var.package_type == "Zip" ? var.handler : null
  runtime                        = var.package_type == "Zip" ? var.runtime : null
  architectures                  = var.architectures
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  kms_key_arn                    = var.kms_key_arn
  package_type                   = var.package_type

  # Source code package configuration
  filename          = var.package_type == "Zip" ? local.filename : null
  source_code_hash  = var.package_type == "Zip" ? local.source_code_hash : null
  s3_bucket         = var.package_type == "Zip" ? var.s3_bucket : null
  s3_key            = var.package_type == "Zip" ? var.s3_key : null
  s3_object_version = var.package_type == "Zip" ? var.s3_object_version : null
  image_uri         = var.package_type == "Image" ? var.image_uri : null

  # Layers & Code Signing
  layers                  = length(local.all_layers) > 0 ? local.all_layers : null
  code_signing_config_arn = local.code_signing_config_arn

  # Security group destruction behavior
  replace_security_groups_on_destroy = var.replace_security_groups_on_destroy
  replacement_security_group_ids     = var.replacement_security_group_ids
  skip_destroy                       = var.skip_destroy

  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # Ephemeral storage (/tmp size)
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  # EFS File system integration
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  # Container image configuration
  dynamic "image_config" {
    for_each = var.package_type == "Image" && var.image_config != null ? [var.image_config] : []
    content {
      command           = image_config.value.command
      entry_point       = image_config.value.entry_point
      working_directory = image_config.value.working_directory
    }
  }

  # Advanced CloudWatch logging options
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      log_format            = logging_config.value.log_format
      application_log_level = logging_config.value.application_log_level
      system_log_level      = logging_config.value.system_log_level
      log_group             = logging_config.value.log_group
    }
  }

  # SnapStart for Java runtimes
  dynamic "snap_start" {
    for_each = var.snap_start ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  # Active tracing with AWS X-Ray
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # VPC Configuration
  dynamic "vpc_config" {
    for_each = local.has_vpc ? [1] : []
    content {
      subnet_ids                  = var.vpc_subnet_ids
      security_group_ids          = var.vpc_security_group_ids
      ipv6_allowed_for_dual_stack = var.ipv6_allowed_for_dual_stack
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
    aws_cloudwatch_log_group.this
  ]
}

################################################################################
# Lambda Function URL
################################################################################

resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  qualifier          = var.function_url_qualifier
  authorization_type = var.function_url_auth_type
  invoke_mode        = var.function_url_invoke_mode

  dynamic "cors" {
    for_each = var.function_url_cors != null ? [var.function_url_cors] : []
    content {
      allow_credentials = cors.value.allow_credentials
      allow_headers     = cors.value.allow_headers
      allow_methods     = cors.value.allow_methods
      allow_origins     = cors.value.allow_origins
      expose_headers    = cors.value.expose_headers
      max_age           = cors.value.max_age
    }
  }
}

################################################################################
# Lambda Permissions (Resource-based Policies)
################################################################################

resource "aws_lambda_permission" "this" {
  for_each = var.lambda_permissions

  statement_id           = each.value.statement_id_prefix == null ? each.key : null
  statement_id_prefix    = each.value.statement_id_prefix
  action                 = each.value.action
  function_name          = aws_lambda_function.this.function_name
  principal              = each.value.principal
  source_arn             = each.value.source_arn
  source_account         = each.value.source_account
  qualifier              = each.value.qualifier
  event_source_token     = each.value.event_source_token
  function_url_auth_type = each.value.function_url_auth_type
  principal_org_id       = each.value.principal_org_id
}

################################################################################
# Lambda Aliases
################################################################################

resource "aws_lambda_alias" "this" {
  for_each = var.aliases

  name             = each.key
  description      = each.value.description
  function_name    = aws_lambda_function.this.function_name
  function_version = each.value.function_version

  dynamic "routing_config" {
    for_each = each.value.additional_version_weights != null ? [1] : []
    content {
      additional_version_weights = each.value.additional_version_weights
    }
  }
}

################################################################################
# Lambda Event Source Mappings
################################################################################

resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mappings

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = each.value.batch_size
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  enabled                            = each.value.enabled
  starting_position                  = each.value.starting_position
  starting_position_timestamp        = each.value.starting_position_timestamp
  maximum_record_age_in_seconds      = each.value.maximum_record_age_in_seconds
  maximum_retry_attempts             = each.value.maximum_retry_attempts
  bisect_batch_on_function_error     = each.value.bisect_batch_on_function_error
  parallelization_factor             = each.value.parallelization_factor
  tumbling_window_in_seconds         = each.value.tumbling_window_in_seconds
  topics                             = each.value.topics
  queues                             = each.value.queues
  function_response_types            = each.value.function_response_types
  kms_key_arn                        = each.value.kms_key_arn

  dynamic "filter_criteria" {
    for_each = each.value.filter_patterns != null ? [1] : []
    content {
      dynamic "filter" {
        for_each = each.value.filter_patterns
        content {
          pattern = filter.value
        }
      }
    }
  }

  dynamic "scaling_config" {
    for_each = each.value.maximum_concurrency != null ? [1] : []
    content {
      maximum_concurrency = each.value.maximum_concurrency
    }
  }

  dynamic "destination_config" {
    for_each = each.value.on_failure_destination_arn != null ? [1] : []
    content {
      on_failure {
        destination_arn = each.value.on_failure_destination_arn
      }
    }
  }

  dynamic "document_db_event_source_config" {
    for_each = each.value.document_db_config != null ? [each.value.document_db_config] : []
    content {
      database_name   = document_db_event_source_config.value.database_name
      collection_name = document_db_event_source_config.value.collection_name
      full_document   = document_db_event_source_config.value.full_document
    }
  }

  dynamic "amazon_managed_kafka_event_source_config" {
    for_each = each.value.kafka_consumer_group_id != null ? [1] : []
    content {
      consumer_group_id = each.value.kafka_consumer_group_id
    }
  }

  dynamic "source_access_configuration" {
    for_each = each.value.source_access_configurations != null ? each.value.source_access_configurations : []
    content {
      type = source_access_configuration.value.type
      uri  = source_access_configuration.value.uri
    }
  }

  tags = merge(
    var.tags,
    each.value.tags
  )
}

################################################################################
# Provisioned Concurrency Configuration
################################################################################

resource "aws_lambda_provisioned_concurrency_config" "this" {
  count = var.provisioned_concurrency_config != null ? 1 : 0

  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = var.provisioned_concurrency_config.qualifier
  provisioned_concurrent_executions = var.provisioned_concurrency_config.provisioned_concurrent_executions
  skip_destroy                      = var.provisioned_concurrency_config.skip_destroy
}
