################################################################################
# General / Core Lambda Function Configuration
################################################################################

variable "function_name" {
  description = "Unique name for the Lambda Function."
  type        = string
}

variable "description" {
  description = "Description of what your Lambda Function does."
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entrypoint in your code (e.g., index.handler, app.lambda_handler)."
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Identifier of the function's runtime (e.g., nodejs20.x, python3.12, java21, provided.al2023)."
  type        = string
  default     = "nodejs20.x"
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda function. Valid values are ['x86_64'] and ['arm64']."
  type        = list(string)
  default     = ["x86_64"]
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime (128 MB to 10,240 MB)."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds (1 to 900 seconds)."
  type        = number
  default     = 3
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. A value of 0 disables execution, -1 removes limits."
  type        = number
  default     = null
}

variable "publish" {
  description = "Whether to publish creation/change as a new Lambda Function Version."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the AWS KMS key used to encrypt your function's environment variables."
  type        = string
  default     = null
}

variable "package_type" {
  description = "The Lambda deployment package type. Valid values are 'Zip' and 'Image'."
  type        = string
  default     = "Zip"
}

variable "code_signing_config_arn" {
  description = "To enable code signing for this function, specify the ARN of a code-signing configuration."
  type        = string
  default     = null
}

variable "replace_security_groups_on_destroy" {
  description = "Whether to replace the security groups on destroy."
  type        = bool
  default     = null
}

variable "replacement_security_group_ids" {
  description = "List of security group IDs to assign to the function's VPC configuration prior to destruction."
  type        = list(string)
  default     = null
}

variable "skip_destroy" {
  description = "Set to true if you do not wish the function to be deleted at destroy time, and instead just remove the function from the Terraform state."
  type        = bool
  default     = false
}

################################################################################
# Packaging & Source Code
################################################################################

variable "filename" {
  description = "Path to the function's deployment package within the local filesystem."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket location containing the function's deployment package."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of an object containing the function's deployment package."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Object version containing the function's deployment package."
  type        = string
  default     = null
}

variable "image_uri" {
  description = "ECR image URI containing the function's deployment package for package_type = 'Image'."
  type        = string
  default     = null
}

variable "create_placeholder_package" {
  description = "Whether to create and deploy an automated bootstrap/placeholder zip archive when no custom code/image is provided."
  type        = bool
  default     = true
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function."
  type        = list(string)
  default     = []
}

################################################################################
# Advanced Lambda Blocks
################################################################################

variable "environment_variables" {
  description = "Map of environment variables that are accessible from the function code during execution."
  type        = map(string)
  default     = {}
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function for VPC connectivity."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs associated with the Lambda function for VPC connectivity."
  type        = list(string)
  default     = []
}

variable "ipv6_allowed_for_dual_stack" {
  description = "Allows outbound IPv6 traffic on VPC enabled functions."
  type        = bool
  default     = false
}

variable "dead_letter_target_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type        = string
  default     = null
}

variable "tracing_mode" {
  description = "Whether to sample and trace a subset of incoming requests with AWS X-Ray. Valid values are 'PassThrough' and 'Active'."
  type        = string
  default     = null
}

variable "ephemeral_storage_size" {
  description = "The size of the Lambda function /tmp directory in MB (512 to 10240)."
  type        = number
  default     = 512
}

variable "file_system_config" {
  description = "Connection settings for an EFS file system mount."
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

variable "image_config" {
  description = "Container image configuration values that override values in the container image Dockerfile."
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  default = null
}

variable "logging_config" {
  description = "Advanced CloudWatch logging configuration for Lambda (JSON/Text format, application log level, system log level, custom log group)."
  type = object({
    log_format            = optional(string, "Text")
    application_log_level = optional(string)
    system_log_level      = optional(string)
    log_group             = optional(string)
  })
  default = null
}

variable "snap_start" {
  description = "Enable SnapStart for faster startup performance on Java runtimes ('PublishedVersions')."
  type        = bool
  default     = false
}

################################################################################
# IAM Execution Role & Policies
################################################################################

variable "create_role" {
  description = "Whether to create a dedicated IAM execution role for the Lambda Function."
  type        = bool
  default     = true
}

variable "lambda_role_arn" {
  description = "Existing IAM role ARN to use for the Lambda function (required if create_role is false)."
  type        = string
  default     = null
}

variable "role_name" {
  description = "Name of the dedicated IAM execution role. Defaults to '$${var.function_name}-role' if null."
  type        = string
  default     = null
}

variable "role_description" {
  description = "Description of the dedicated IAM execution role."
  type        = string
  default     = "Execution role for AWS Lambda function"
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role."
  type        = string
  default     = null
}

variable "role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the Lambda execution role."
  type        = list(string)
  default     = []
}

variable "custom_policy_statements" {
  description = "List of custom IAM policy statements to embed directly into the Lambda execution role."
  type        = any
  default     = []
}

variable "role_tags" {
  description = "Additional tags for the created IAM role."
  type        = map(string)
  default     = {}
}

################################################################################
# CloudWatch Log Group
################################################################################

variable "create_log_group" {
  description = "Whether to create a dedicated CloudWatch Log Group for the Lambda function (/aws/lambda/<function_name>)."
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group (0 = never expire)."
  type        = number
  default     = 14
}

variable "log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}

variable "log_group_class" {
  description = "Specified the log class of the log group. Possible values are 'STANDARD' or 'INFREQUENT_ACCESS'."
  type        = string
  default     = null
}

################################################################################
# Lambda Function URL
################################################################################

variable "create_function_url" {
  description = "Whether to create a dedicated HTTPS Function URL for direct HTTP invocation."
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "The type of authentication that your function URL uses. Valid values are 'NONE' and 'AWS_IAM'."
  type        = string
  default     = "NONE"
}

variable "function_url_invoke_mode" {
  description = "Determines how the Lambda function responds to an HTTP request. Valid values are 'BUFFERED' and 'RESPONSE_STREAM'."
  type        = string
  default     = "BUFFERED"
}

variable "function_url_qualifier" {
  description = "The alias name or version number to associate with the function URL. Omit to associate with $LATEST."
  type        = string
  default     = null
}

variable "function_url_cors" {
  description = "CORS settings for the function URL."
  type = object({
    allow_credentials = optional(bool)
    allow_headers     = optional(list(string))
    allow_methods     = optional(list(string))
    allow_origins     = optional(list(string))
    expose_headers    = optional(list(string))
    max_age           = optional(number)
  })
  default = null
}

################################################################################
# Lambda Permissions (Resource-based Policies)
################################################################################

variable "lambda_permissions" {
  description = "Map of Lambda permissions granting external services (e.g. S3, API Gateway, SNS, EventBridge) permission to invoke the function."
  type = map(object({
    action                 = optional(string, "lambda:InvokeFunction")
    principal              = string
    source_arn             = optional(string)
    source_account         = optional(string)
    qualifier              = optional(string)
    event_source_token     = optional(string)
    function_url_auth_type = optional(string)
    principal_org_id       = optional(string)
    statement_id_prefix    = optional(string)
  }))
  default = {}
}

################################################################################
# Lambda Aliases
################################################################################

variable "aliases" {
  description = "Map of Lambda aliases to create."
  type = map(object({
    function_version           = optional(string, "$LATEST")
    description                = optional(string)
    additional_version_weights = optional(map(number))
  }))
  default = {}
}

################################################################################
# Lambda Event Source Mappings
################################################################################

variable "event_source_mappings" {
  description = "Map of event source mappings (SQS, DynamoDB Streams, Kinesis, Kafka) to trigger the function."
  type = map(object({
    event_source_arn                   = optional(string)
    batch_size                         = optional(number)
    maximum_batching_window_in_seconds = optional(number)
    enabled                            = optional(bool, true)
    starting_position                  = optional(string)
    starting_position_timestamp        = optional(string)
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    bisect_batch_on_function_error     = optional(bool)
    parallelization_factor             = optional(number)
    tumbling_window_in_seconds         = optional(number)
    topics                             = optional(list(string))
    queues                             = optional(list(string))
    function_response_types            = optional(list(string))
    kms_key_arn                        = optional(string)
    filter_patterns                    = optional(list(string))
    maximum_concurrency                = optional(number)
    on_failure_destination_arn         = optional(string)
    document_db_config = optional(object({
      database_name   = string
      collection_name = optional(string)
      full_document   = optional(string)
    }))
    kafka_consumer_group_id      = optional(string)
    source_access_configurations = optional(list(object({ type = string, uri = string })))
    tags                         = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Provisioned Concurrency Configuration
################################################################################

variable "provisioned_concurrency_config" {
  description = "Provisioned concurrency configuration for warm Lambda execution environments."
  type = object({
    qualifier                         = string
    provisioned_concurrent_executions = number
    skip_destroy                      = optional(bool, false)
  })
  default = null
}

################################################################################
# Lambda Layer Versions to Create
################################################################################

variable "layers_to_create" {
  description = "Map of Lambda Layer Versions to create alongside the function."
  type = map(object({
    filename                 = optional(string)
    s3_bucket                = optional(string)
    s3_key                   = optional(string)
    s3_object_version        = optional(string)
    compatible_runtimes      = optional(list(string))
    compatible_architectures = optional(list(string))
    description              = optional(string)
    license_info             = optional(string)
    source_code_hash         = optional(string)
    skip_destroy             = optional(bool, false)
  }))
  default = {}
}

################################################################################
# Code Signing Configuration
################################################################################

variable "code_signing_config" {
  description = "Code signing configuration to create for the function."
  type = object({
    signing_profile_version_arns     = list(string)
    untrusted_artifact_on_deployment = optional(string, "Warn")
    description                      = optional(string)
  })
  default = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
