data "aws_partition" "current" {}

locals {
  # How each origin reaches its bucket, with an unset origin_access resolved from the fields that
  # were set — see the origins variable.
  origin_access = {
    for o in var.origins : o.origin_id => (
      !o.is_s3_origin ? "none" :
      o.origin_access != null ? o.origin_access :
      try(trimspace(o.origin_access_control_id), "") != "" ? "existing_oac" :
      try(trimspace(o.s3_origin_access_identity), "") != "" ? "oai" :
      "create_oac"
    )
  }

  # The bucket behind an S3 REST endpoint: <bucket>.s3.amazonaws.com or
  # <bucket>.s3.<region>.amazonaws.com. A website endpoint (s3-website-…) does not match — it is a
  # custom origin, and Origin Access Control cannot sign requests to it.
  s3_bucket = {
    for o in var.origins : o.origin_id =>
    try(regex("^(.+)\\.s3(\\.[a-z0-9-]+)*\\.amazonaws\\.com(\\.cn)?$", o.domain_name)[0], null)
    if o.is_s3_origin
  }

  oac_origins = { for o in var.origins : o.origin_id => o if contains(["create_oac", "existing_oac"], local.origin_access[o.origin_id]) }

  # The policy a bucket needs for this distribution to read it through OAC: the CloudFront service
  # principal, limited by AWS:SourceArn to this distribution alone.
  oac_bucket_policies = {
    for bucket in distinct(compact([for id, o in local.oac_origins : local.s3_bucket[id]])) : bucket => jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "arn:${data.aws_partition.current.partition}:s3:::${bucket}/*"
        Condition = { StringEquals = { "AWS:SourceArn" = aws_cloudfront_distribution.this.arn } }
      }]
    })
  }

  granted_buckets = toset(compact([for id, o in local.oac_origins : o.grant_s3_read_access ? local.s3_bucket[id] : null]))
}

################################################################################
# Origin Access Control
################################################################################

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = { for id, o in local.oac_origins : id => o if local.origin_access[id] == "create_oac" }

  name                              = coalesce(each.value.oac_name, substr("${var.name}-${each.key}", 0, 64))
  description                       = substr("S3 access for CloudFront distribution ${var.name}, origin ${each.key}", 0, 256)
  origin_access_control_origin_type = "s3"
  signing_behavior                  = each.value.oac_signing_behavior
  signing_protocol                  = "sigv4"
}

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
      origin_id   = origin.value.origin_id
      domain_name = origin.value.domain_name
      origin_path = origin.value.origin_path
      origin_access_control_id = (
        local.origin_access[origin.key] == "create_oac" ? aws_cloudfront_origin_access_control.this[origin.key].id :
        local.origin_access[origin.key] == "existing_oac" ? origin.value.origin_access_control_id :
        null
      )
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      dynamic "s3_origin_config" {
        for_each = local.origin_access[origin.key] == "oai" ? [""] : []
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
      condition     = var.acm_certificate_arn == null || split(":", var.acm_certificate_arn)[3] == "us-east-1"
      error_message = "acm_certificate_arn must be a certificate in us-east-1 -- CloudFront only accepts certificates from that region, regardless of this distribution's own region."
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
        local.origin_access[o.origin_id] != "existing_oac" || try(trimspace(o.origin_access_control_id), "") != ""
      ])
      error_message = "An S3 origin with origin_access 'existing_oac' needs origin_access_control_id."
    }
    precondition {
      condition = alltrue([
        for o in var.origins :
        local.origin_access[o.origin_id] != "oai" || try(trimspace(o.s3_origin_access_identity), "") != ""
      ])
      error_message = "An S3 origin with origin_access 'oai' needs s3_origin_access_identity."
    }
    precondition {
      condition     = alltrue([for id, o in local.oac_origins : local.s3_bucket[id] != null])
      error_message = "An S3 origin using Origin Access Control needs the bucket's REST endpoint as its domain, <bucket>.s3.<region>.amazonaws.com. A website endpoint (s3-website-…) must be a custom origin instead."
    }
    precondition {
      condition     = alltrue([for o in var.origins : !o.grant_s3_read_access || contains(keys(local.oac_origins), o.origin_id)])
      error_message = "grant_s3_read_access works only for S3 origins using Origin Access Control (create_oac or existing_oac)."
    }
  }
}

################################################################################
# Bucket access for Origin Access Control (opt-in)
################################################################################

# Replaces the bucket's whole policy: S3 holds one per bucket. Only for buckets nothing else gives a
# policy to — the S3 module's bucket_policy included — or the two would overwrite each other on
# every apply. Otherwise add the statement from the s3_bucket_policies output to that policy.
resource "aws_s3_bucket_policy" "oac" {
  for_each = local.granted_buckets

  bucket = each.key
  policy = local.oac_bucket_policies[each.key]
}
