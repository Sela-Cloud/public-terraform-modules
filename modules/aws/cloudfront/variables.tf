variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests."
  type        = bool
  default     = true
}

variable "comment" {
  description = "Free-text comment for the distribution."
  type        = string
  default     = null
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) this distribution answers for."
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Object to return for requests to the root URL, e.g. index.html."
  type        = string
  default     = null
}

variable "price_class" {
  description = "Which edge locations serve this distribution."
  type        = string
  default     = "PriceClass_All"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "price_class must be 'PriceClass_All', 'PriceClass_200', or 'PriceClass_100'."
  }
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution."
  type        = bool
  default     = true
}

variable "http_version" {
  description = "Maximum HTTP version viewers may use."
  type        = string
  default     = "http2"

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "http_version must be 'http1.1', 'http2', 'http2and3', or 'http3'."
  }
}

variable "web_acl_id" {
  description = "AWS WAF web ACL ARN to associate with the distribution."
  type        = string
  default     = null
}

variable "origins" {
  description = "Origins the distribution can pull content from. At least one is required."
  type = list(object({
    origin_id   = string
    domain_name = string
    origin_path = optional(string)

    # S3 origin (is_s3_origin = true): pick one of origin_access_control_id (recommended, OAC) or
    # s3_origin_access_identity (legacy OAI, still real and still issued, kept for existing setups).
    is_s3_origin              = optional(bool, false)
    origin_access_control_id  = optional(string)
    s3_origin_access_identity = optional(string)

    # Custom origin (is_s3_origin = false) -- an ALB, another web server, or an S3 static-website
    # endpoint (which is a custom origin, not an S3 origin, because website endpoints don't support
    # the S3 REST API OAC/OAI use).
    http_port              = optional(number, 80)
    https_port             = optional(number, 443)
    origin_protocol_policy = optional(string, "https-only")
    origin_ssl_protocols   = optional(list(string), ["TLSv1.2"])

    connection_attempts = optional(number, 3)
    connection_timeout  = optional(number, 10)
    custom_headers      = optional(map(string), {})

    origin_shield_enabled = optional(bool, false)
    origin_shield_region  = optional(string)
  }))

  validation {
    condition     = length(var.origins) > 0
    error_message = "At least one origin is required."
  }

  validation {
    condition     = length(distinct([for o in var.origins : o.origin_id])) == length(var.origins)
    error_message = "Each origin's origin_id must be unique."
  }
}

variable "target_origin_id" {
  description = "origin_id of the origin the default cache behavior routes to."
  type        = string
}

variable "viewer_protocol_policy" {
  description = "How CloudFront responds to HTTP viewer requests."
  type        = string
  default     = "redirect-to-https"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "viewer_protocol_policy must be 'allow-all', 'https-only', or 'redirect-to-https'."
  }
}

variable "allowed_methods" {
  description = "HTTP methods CloudFront processes and forwards to the origin."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "HTTP methods CloudFront caches responses for."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Whether CloudFront automatically compresses certain file types."
  type        = bool
  default     = true
}

variable "cache_policy_id" {
  description = "Managed or custom cache policy ID. Defaults to AWS's 'CachingOptimized' managed policy, matching the console's own default."
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "origin_request_policy_id" {
  description = "Managed or custom origin request policy ID."
  type        = string
  default     = null
}

variable "response_headers_policy_id" {
  description = "Managed or custom response headers policy ID."
  type        = string
  default     = null
}

variable "field_level_encryption_id" {
  description = "Field-level encryption configuration ID."
  type        = string
  default     = null
}

variable "realtime_log_config_arn" {
  description = "Real-time log configuration ARN."
  type        = string
  default     = null
}

variable "use_default_certificate" {
  description = "Use the default *.cloudfront.net certificate. Set to false and provide acm_certificate_arn for a custom domain over HTTPS."
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the alternate domain names in `aliases`. Must be in us-east-1. Required when use_default_certificate is false."
  type        = string
  default     = null
}

variable "ssl_support_method" {
  description = "How CloudFront serves HTTPS for a custom certificate."
  type        = string
  default     = "sni-only"

  validation {
    condition     = contains(["sni-only", "vip", "static-ip"], var.ssl_support_method)
    error_message = "ssl_support_method must be 'sni-only', 'vip', or 'static-ip'."
  }
}

variable "minimum_protocol_version" {
  description = "Minimum TLS version for viewer connections over HTTPS with a custom certificate."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "geo_restriction_type" {
  description = "Whether to restrict content by viewer country."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "geo_restriction_type must be 'none', 'whitelist', or 'blacklist'."
  }
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes for the geo restriction. Required when geo_restriction_type is not 'none'."
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Whether to write standard access logs to an S3 bucket."
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "S3 bucket (regional domain name, e.g. my-logs.s3.amazonaws.com) to write access logs to. Required when enable_logging is true."
  type        = string
  default     = null
}

variable "logging_prefix" {
  description = "Prefix for access log object keys."
  type        = string
  default     = null
}

variable "logging_include_cookies" {
  description = "Whether to include cookies in access logs."
  type        = bool
  default     = false
}

variable "custom_error_responses" {
  description = "Custom responses for specific origin error status codes."
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the distribution."
  type        = map(string)
  default     = {}
}
