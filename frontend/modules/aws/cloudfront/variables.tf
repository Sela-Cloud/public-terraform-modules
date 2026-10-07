variable "region" {
  description = "The AWS region where resources will be provisioned. CloudFront itself is global; this only affects the provider used to create it."
  type        = string
  default     = "us-east-1"
}

variable "cloudfront" {
  description = "Map of CloudFront distributions to create, keyed by an arbitrary resource name."
  type = map(object({
    enabled             = optional(bool, true)
    comment             = optional(string)
    aliases             = optional(list(string), [])
    default_root_object = optional(string)
    price_class         = optional(string, "PriceClass_All")
    is_ipv6_enabled     = optional(bool, true)
    http_version        = optional(string, "http2")
    web_acl_id          = optional(string)

    origins = list(object({
      origin_id                 = string
      domain_name               = string
      origin_path               = optional(string)
      is_s3_origin              = optional(bool, false)
      origin_access_control_id  = optional(string)
      s3_origin_access_identity = optional(string)
      http_port                 = optional(number, 80)
      https_port                = optional(number, 443)
      origin_protocol_policy    = optional(string, "https-only")
      origin_ssl_protocols      = optional(list(string), ["TLSv1.2"])
      connection_attempts       = optional(number, 3)
      connection_timeout        = optional(number, 10)
      custom_headers            = optional(map(string), {})
      origin_shield_enabled     = optional(bool, false)
      origin_shield_region      = optional(string)
    }))

    origin_groups = optional(list(object({
      origin_group_id       = string
      failover_status_codes = optional(list(number), [500, 502, 503, 504])
      primary_origin_id     = string
      secondary_origin_id   = string
    })), [])

    target_origin_id           = string
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string, "658327ea-f89d-4fab-a63d-7e88639e58f6")
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
    field_level_encryption_id  = optional(string)
    realtime_log_config_arn    = optional(string)

    ordered_cache_behaviors = optional(list(object({
      path_pattern               = string
      target_origin_id           = string
      viewer_protocol_policy     = optional(string, "redirect-to-https")
      allowed_methods            = optional(list(string), ["GET", "HEAD"])
      cached_methods             = optional(list(string), ["GET", "HEAD"])
      compress                   = optional(bool, true)
      cache_policy_id            = optional(string, "658327ea-f89d-4fab-a63d-7e88639e58f6")
      origin_request_policy_id   = optional(string)
      response_headers_policy_id = optional(string)
      field_level_encryption_id  = optional(string)
      realtime_log_config_arn    = optional(string)
    })), [])

    use_default_certificate  = optional(bool, true)
    acm_certificate_arn      = optional(string)
    ssl_support_method       = optional(string, "sni-only")
    minimum_protocol_version = optional(string, "TLSv1.2_2021")

    geo_restriction_type      = optional(string, "none")
    geo_restriction_locations = optional(list(string), [])

    enable_logging          = optional(bool, false)
    logging_bucket          = optional(string)
    logging_prefix          = optional(string)
    logging_include_cookies = optional(bool, false)

    custom_error_responses = optional(list(object({
      error_code            = number
      response_code         = optional(number)
      response_page_path    = optional(string)
      error_caching_min_ttl = optional(number)
    })), [])

    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for c in values(var.cloudfront) : length(c.origins) > 0])
    error_message = "At least one origin is required."
  }

  validation {
    condition = alltrue([
      for c in values(var.cloudfront) : contains(
        concat([for o in c.origins : o.origin_id], [for g in c.origin_groups : g.origin_group_id]),
        c.target_origin_id
      )
    ])
    error_message = "target_origin_id must match the origin_id of one of the origins, or an origin_group_id in origin_groups."
  }

  validation {
    condition = alltrue(flatten([
      for c in values(var.cloudfront) : [
        for g in c.origin_groups :
        contains([for o in c.origins : o.origin_id], g.primary_origin_id) &&
        contains([for o in c.origins : o.origin_id], g.secondary_origin_id)
      ]
    ]))
    error_message = "origin_groups' primary_origin_id and secondary_origin_id must each match a real origin_id in origins."
  }

  validation {
    condition = alltrue(flatten([
      for c in values(var.cloudfront) : [
        for b in c.ordered_cache_behaviors :
        contains(
          concat([for o in c.origins : o.origin_id], [for g in c.origin_groups : g.origin_group_id]),
          b.target_origin_id
        )
      ]
    ]))
    error_message = "Each ordered_cache_behaviors entry's target_origin_id must match an origin_id or origin_group_id."
  }

  validation {
    condition = alltrue([
      for c in values(var.cloudfront) : c.use_default_certificate || c.acm_certificate_arn != null
    ])
    error_message = "acm_certificate_arn is required when use_default_certificate is false."
  }

  validation {
    condition = alltrue([
      for c in values(var.cloudfront) : c.geo_restriction_type == "none" || length(c.geo_restriction_locations) > 0
    ])
    error_message = "geo_restriction_locations is required when geo_restriction_type is not 'none'."
  }

  validation {
    condition = alltrue([
      for c in values(var.cloudfront) : !c.enable_logging || c.logging_bucket != null
    ])
    error_message = "logging_bucket is required when enable_logging is true."
  }

  validation {
    condition = alltrue(flatten([
      for c in values(var.cloudfront) : [
        for o in c.origins : !o.is_s3_origin || (o.origin_access_control_id != null || o.s3_origin_access_identity != null)
      ]
    ]))
    error_message = "Every S3 origin needs either origin_access_control_id (recommended) or s3_origin_access_identity (legacy)."
  }
}
