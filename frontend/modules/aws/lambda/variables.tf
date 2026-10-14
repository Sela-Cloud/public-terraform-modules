variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "lambda" {
  description = "Map of Lambda Function configurations to deploy, keyed by function name."
  type = map(object({
    function_name                  = optional(string, null)
    description                    = optional(string, null)
    handler                        = optional(string, "index.handler")
    runtime                        = optional(string, "nodejs20.x")
    architectures                  = optional(list(string), ["x86_64"])
    memory_size                    = optional(number, 128)
    timeout                        = optional(number, 3)
    reserved_concurrent_executions = optional(number, null)
    publish                        = optional(bool, false)
    kms_key_arn                    = optional(string, null)
    package_type                   = optional(string, "Zip")
    code_signing_config_arn        = optional(string, null)

    replace_security_groups_on_destroy = optional(bool, null)
    replacement_security_group_ids     = optional(list(string), null)
    skip_destroy                       = optional(bool, false)

    filename                   = optional(string, null)
    source_code_hash           = optional(string, null)
    s3_bucket                  = optional(string, null)
    s3_key                     = optional(string, null)
    s3_object_version          = optional(string, null)
    image_uri                  = optional(string, null)
    create_placeholder_package = optional(bool, true)
    layers                     = optional(list(string), [])

    environment_variables       = optional(map(string), {})
    vpc_subnet_ids              = optional(list(string), [])
    vpc_security_group_ids      = optional(list(string), [])
    ipv6_allowed_for_dual_stack = optional(bool, false)
    dead_letter_target_arn      = optional(string, null)
    tracing_mode                = optional(string, null)
    ephemeral_storage_size      = optional(number, 512)

    file_system_config = optional(object({
      arn              = string
      local_mount_path = string
    }), null)

    image_config = optional(object({
      command           = optional(list(string), null)
      entry_point       = optional(list(string), null)
      working_directory = optional(string, null)
    }), null)

    logging_config = optional(object({
      log_format            = optional(string, "Text")
      application_log_level = optional(string, null)
      system_log_level      = optional(string, null)
      log_group             = optional(string, null)
    }), null)

    snap_start = optional(bool, false)

    create_role              = optional(bool, true)
    lambda_role_arn          = optional(string, null)
    role_name                = optional(string, null)
    role_description         = optional(string, "Execution role for AWS Lambda function")
    permissions_boundary     = optional(string, null)
    role_policy_arns         = optional(list(string), [])
    custom_policy_statements = optional(string, null)
    role_tags                = optional(map(string), {})

    create_log_group      = optional(bool, true)
    log_retention_in_days = optional(number, 14)
    log_group_kms_key_id  = optional(string, null)
    log_group_class       = optional(string, null)

    create_function_url      = optional(bool, false)
    function_url_auth_type   = optional(string, "NONE")
    function_url_invoke_mode = optional(string, "BUFFERED")
    function_url_qualifier   = optional(string, null)
    function_url_cors = optional(object({
      allow_credentials = optional(bool, null)
      allow_headers     = optional(list(string), null)
      allow_methods     = optional(list(string), null)
      allow_origins     = optional(list(string), null)
      expose_headers    = optional(list(string), null)
      max_age           = optional(number, null)
    }), null)

    lambda_permissions = optional(list(object({
      key                    = string
      action                 = optional(string, "lambda:InvokeFunction")
      principal              = string
      source_arn             = optional(string, null)
      source_account         = optional(string, null)
      qualifier              = optional(string, null)
      event_source_token     = optional(string, null)
      function_url_auth_type = optional(string, null)
      principal_org_id       = optional(string, null)
      statement_id_prefix    = optional(string, null)
    })), [])

    aliases = optional(list(object({
      key                        = string
      function_version           = optional(string, "$LATEST")
      description                = optional(string, null)
      additional_version_weights = optional(map(number), null)
    })), [])

    event_source_mappings = optional(list(object({
      key                                = string
      event_source_arn                   = optional(string, null)
      batch_size                         = optional(number, null)
      maximum_batching_window_in_seconds = optional(number, null)
      enabled                            = optional(bool, true)
      starting_position                  = optional(string, null)
      starting_position_timestamp        = optional(string, null)
      maximum_record_age_in_seconds      = optional(number, null)
      maximum_retry_attempts             = optional(number, null)
      bisect_batch_on_function_error     = optional(bool, null)
      parallelization_factor             = optional(number, null)
      tumbling_window_in_seconds         = optional(number, null)
      topics                             = optional(list(string), null)
      queues                             = optional(list(string), null)
      function_response_types            = optional(list(string), null)
      kms_key_arn                        = optional(string, null)
      filter_patterns                    = optional(list(string), null)
      maximum_concurrency                = optional(number, null)
      on_failure_destination_arn         = optional(string, null)
      document_db_config = optional(object({
        database_name   = string
        collection_name = optional(string, null)
        full_document   = optional(string, null)
      }), null)
      kafka_consumer_group_id      = optional(string, null)
      source_access_configurations = optional(list(object({ type = string, uri = string })), null)
      tags                         = optional(map(string), {})
    })), [])

    provisioned_concurrency_config = optional(object({
      qualifier                         = string
      provisioned_concurrent_executions = number
      skip_destroy                      = optional(bool, false)
    }), null)

    layers_to_create = optional(list(object({
      key                      = string
      filename                 = optional(string, null)
      s3_bucket                = optional(string, null)
      s3_key                   = optional(string, null)
      s3_object_version        = optional(string, null)
      compatible_runtimes      = optional(list(string), null)
      compatible_architectures = optional(list(string), null)
      description              = optional(string, null)
      license_info             = optional(string, null)
      source_code_hash         = optional(string, null)
      skip_destroy             = optional(bool, false)
    })), [])

    code_signing_config = optional(object({
      signing_profile_version_arns     = list(string)
      untrusted_artifact_on_deployment = optional(string, "Warn")
      description                      = optional(string, null)
    }), null)

    tags = optional(map(string), {})
  }))
  default = {}
}
