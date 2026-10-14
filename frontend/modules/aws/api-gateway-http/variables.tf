variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "api_gateway_http" {
  description = "Map of HTTP API configurations to deploy, keyed by name."
  type = map(object({
    name                         = optional(string, null)
    description                  = optional(string, null)
    disable_execute_api_endpoint = optional(bool, false)

    cors_configuration = optional(object({
      allow_credentials = optional(bool, null)
      allow_headers     = optional(list(string), null)
      allow_methods     = optional(list(string), null)
      allow_origins     = optional(list(string), null)
      expose_headers    = optional(list(string), null)
      max_age           = optional(number, null)
    }), null)

    routes = optional(list(object({
      key                    = string
      route_key              = string
      authorization_type     = optional(string, "NONE")
      authorizer_key         = optional(string, null)
      api_key_required       = optional(bool, false)
      integration_type       = string
      lambda_function_arn    = optional(string, null)
      integration_uri        = optional(string, null)
      connection_type        = optional(string, "INTERNET")
      connection_id          = optional(string, null)
      payload_format_version = optional(string, "2.0")
      timeout_milliseconds   = optional(number, null)
    })), [])

    authorizers = optional(list(object({
      key                               = string
      name                              = string
      authorizer_type                   = string
      identity_sources                  = optional(list(string), [])
      jwt_issuer                        = optional(string, null)
      jwt_audience                      = optional(list(string), null)
      authorizer_lambda_arn             = optional(string, null)
      authorizer_payload_format_version = optional(string, "2.0")
      enable_simple_responses           = optional(bool, false)
      authorizer_result_ttl_in_seconds  = optional(number, null)
    })), [])

    stage_name                 = optional(string, "$default")
    auto_deploy                = optional(bool, true)
    access_log_destination_arn = optional(string, null)
    access_log_format          = optional(string, null)

    default_route_settings = optional(object({
      throttling_burst_limit   = optional(number, null)
      throttling_rate_limit    = optional(number, null)
      detailed_metrics_enabled = optional(bool, false)
    }), {})

    create_vpc_link             = optional(bool, false)
    vpc_link_security_group_ids = optional(list(string), [])
    vpc_link_subnet_ids         = optional(list(string), [])

    domain_name     = optional(string, null)
    certificate_arn = optional(string, null)
    security_policy = optional(string, "TLS_1_2")
    api_mapping_key = optional(string, null)

    tags = optional(map(string), {})
  }))
  default = {}
}
