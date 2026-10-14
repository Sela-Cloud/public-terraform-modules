################################################################################
# General
################################################################################

variable "name" {
  description = "Name of the HTTP API, applied as the 'Name' tag."
  type        = string
  default     = "http-api-default"
}

variable "description" {
  description = "Description of the HTTP API."
  type        = string
  default     = null
}

variable "disable_execute_api_endpoint" {
  description = "Whether to disable the default execute-api endpoint. Set this if you only want traffic through a custom domain name."
  type        = bool
  default     = false
}

variable "cors_configuration" {
  description = "Cross-origin resource sharing configuration. Leave null to disable CORS."
  type = object({
    allow_credentials = optional(bool, null)
    allow_headers     = optional(list(string), null)
    allow_methods     = optional(list(string), null)
    allow_origins     = optional(list(string), null)
    expose_headers    = optional(list(string), null)
    max_age           = optional(number, null)
  })
  default = null
}

################################################################################
# Routes
################################################################################

variable "routes" {
  description = <<-EOT
    Routes, each with its own integration. Each needs a unique key (Terraform-only, not sent to
    AWS). integration_type is 'AWS_PROXY' (Lambda, requires lambda_function_arn) or 'HTTP_PROXY'
    (HTTP backend or private ALB/NLB via a VPC Link, requires integration_uri). authorizer_key, if
    set, must match an authorizers entry's key defined below.
  EOT
  type = list(object({
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
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.routes : contains(["NONE", "JWT", "AWS_IAM", "CUSTOM"], r.authorization_type)])
    error_message = "Each route's authorization_type must be one of 'NONE', 'JWT', 'AWS_IAM', 'CUSTOM'."
  }

  validation {
    condition     = alltrue([for r in var.routes : contains(["1.0", "2.0"], r.payload_format_version)])
    error_message = "Each route's payload_format_version must be '1.0' or '2.0'."
  }

  validation {
    condition     = alltrue([for r in var.routes : contains(["INTERNET", "VPC_LINK"], r.connection_type)])
    error_message = "Each route's connection_type must be 'INTERNET' or 'VPC_LINK'."
  }
}

################################################################################
# Authorizers
################################################################################

variable "authorizers" {
  description = "Authorizers, referenced by routes via authorizer_key. Each needs a unique key (Terraform-only, not sent to AWS). authorizer_type is 'JWT' (requires jwt_issuer) or 'REQUEST' (Lambda, requires authorizer_lambda_arn)."
  type = list(object({
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
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.authorizers : contains(["JWT", "REQUEST"], a.authorizer_type)])
    error_message = "Each authorizer's authorizer_type must be 'JWT' or 'REQUEST'."
  }
}

################################################################################
# Stage
################################################################################

variable "stage_name" {
  description = "Name of the deployment stage."
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether route/integration changes deploy automatically. When false, an explicit aws_apigatewayv2_deployment is created and redeployed whenever routes change."
  type        = bool
  default     = true
}

variable "access_log_destination_arn" {
  description = "CloudWatch Logs log group ARN for access logs. Leave null to disable access logging. No lookup is wired here, since this catalog does not yet have a CloudWatch Logs log-group lookup -- enter the ARN directly."
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Access log format string. Leave null for a sensible default JSON format."
  type        = string
  default     = null
}

variable "default_route_settings" {
  description = "Default throttling and logging settings applied to every route in the stage."
  type = object({
    throttling_burst_limit   = optional(number, null)
    throttling_rate_limit    = optional(number, null)
    detailed_metrics_enabled = optional(bool, false)
  })
  default = {}
}

################################################################################
# VPC Link
################################################################################

variable "create_vpc_link" {
  description = "Whether to create a VPC Link, for routes with connection_type = 'VPC_LINK' targeting a private ALB/NLB listener or AWS Cloud Map service."
  type        = bool
  default     = false
}

variable "vpc_link_security_group_ids" {
  description = "Security group IDs for the VPC Link's ENIs. Required when create_vpc_link is true."
  type        = list(string)
  default     = []
}

variable "vpc_link_subnet_ids" {
  description = "Subnet IDs for the VPC Link's ENIs. Required when create_vpc_link is true."
  type        = list(string)
  default     = []
}

################################################################################
# Custom Domain
################################################################################

variable "domain_name" {
  description = "Custom domain name for the API. Leave null to only use the default execute-api endpoint."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain, in this API's own region (HTTP API custom domains are regional-only -- no edge-optimized option, unlike REST APIs). Required when domain_name is set."
  type        = string
  default     = null
}

variable "security_policy" {
  description = "TLS security policy for the custom domain."
  type        = string
  default     = "TLS_1_2"
}

variable "api_mapping_key" {
  description = "Path prefix under the custom domain that maps to this API's stage, e.g. 'v1'. Leave null to map the domain's root."
  type        = string
  default     = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
