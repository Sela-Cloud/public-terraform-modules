################################################################################
# CloudFront Distribution
################################################################################

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  comment             = var.comment
  aliases             = var.aliases
  default_root_object = var.default_root_object
  price_class         = var.price_class
  is_ipv6_enabled     = var.is_ipv6_enabled
  http_version        = var.http_version
  web_acl_id          = var.web_acl_id

  dynamic "origin" {
    for_each = { for o in var.origins : o.origin_id => o }
    content {
      origin_id                = origin.value.origin_id
      domain_name              = origin.value.domain_name
      origin_path              = origin.value.origin_path
      origin_access_control_id = origin.value.is_s3_origin ? origin.value.origin_access_control_id : null
      connection_attempts      = origin.value.connection_attempts
      connection_timeout       = origin.value.connection_timeout

      dynamic "s3_origin_config" {
        for_each = origin.value.is_s3_origin && origin.value.s3_origin_access_identity != null ? [""] : []
        content {
          origin_access_identity = origin.value.s3_origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.is_s3_origin ? [] : [""]
        content {
          http_port              = origin.value.http_port
          https_port             = origin.value.https_port
          origin_protocol_policy = origin.value.origin_protocol_policy
          origin_ssl_protocols   = origin.value.origin_ssl_protocols
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield_enabled ? [""] : []
        content {
          enabled              = true
          origin_shield_region = origin.value.origin_shield_region
        }
      }
    }
  }

  dynamic "origin_group" {
    for_each = { for g in var.origin_groups : g.origin_group_id => g }
    content {
      origin_id = origin_group.value.origin_group_id

      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }

      member {
        origin_id = origin_group.value.primary_origin_id
      }
      member {
        origin_id = origin_group.value.secondary_origin_id
      }
    }
  }

  default_cache_behavior {
    target_origin_id           = var.target_origin_id
    viewer_protocol_policy     = var.viewer_protocol_policy
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    compress                   = var.compress
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    field_level_encryption_id  = var.field_level_encryption_id
    realtime_log_config_arn    = var.realtime_log_config_arn
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      compress                   = ordered_cache_behavior.value.compress
      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
      field_level_encryption_id  = ordered_cache_behavior.value.field_level_encryption_id
      realtime_log_config_arn    = ordered_cache_behavior.value.realtime_log_config_arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.use_default_certificate ? true : null
    acm_certificate_arn            = var.use_default_certificate ? null : var.acm_certificate_arn
    ssl_support_method             = var.use_default_certificate ? null : var.ssl_support_method
    minimum_protocol_version       = var.use_default_certificate ? null : var.minimum_protocol_version
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [""] : []
    content {
      bucket          = var.logging_bucket
      prefix          = var.logging_prefix
      include_cookies = var.logging_include_cookies
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = contains(
        concat([for o in var.origins : o.origin_id], [for g in var.origin_groups : g.origin_group_id]),
        var.target_origin_id
      )
      error_message = "target_origin_id must match the origin_id of one of the origins, or an origin_group_id in var.origin_groups."
    }
    precondition {
      condition = alltrue([
        for g in var.origin_groups :
        contains([for o in var.origins : o.origin_id], g.primary_origin_id) &&
        contains([for o in var.origins : o.origin_id], g.secondary_origin_id)
      ])
      error_message = "origin_groups' primary_origin_id and secondary_origin_id must each match a real origin_id in var.origins."
    }
    precondition {
      condition = alltrue([
        for b in var.ordered_cache_behaviors : contains(
          concat([for o in var.origins : o.origin_id], [for g in var.origin_groups : g.origin_group_id]),
          b.target_origin_id
        )
      ])
      error_message = "Each ordered_cache_behaviors entry's target_origin_id must match an origin_id or origin_group_id."
    }
    precondition {
      condition     = var.use_default_certificate || var.acm_certificate_arn != null
      error_message = "acm_certificate_arn is required when use_default_certificate is false."
    }
    precondition {
      condition     = var.geo_restriction_type == "none" || length(var.geo_restriction_locations) > 0
      error_message = "geo_restriction_locations is required when geo_restriction_type is not 'none'."
    }
    precondition {
      condition     = !var.enable_logging || var.logging_bucket != null
      error_message = "logging_bucket is required when enable_logging is true."
    }
    precondition {
      condition = alltrue([
        for o in var.origins :
        !o.is_s3_origin || (o.origin_access_control_id != null || o.s3_origin_access_identity != null)
      ])
      error_message = "Every S3 origin needs either origin_access_control_id (recommended) or s3_origin_access_identity (legacy)."
    }
  }
}
