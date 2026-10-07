/******************************************
  CloudFront Distribution Root Module
 *****************************************/

module "cloudfront" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/cloudfront?ref=v0.8.15"
  for_each = var.cloudfront

  enabled             = each.value.enabled
  comment             = each.value.comment
  aliases             = each.value.aliases
  default_root_object = each.value.default_root_object
  price_class         = each.value.price_class
  is_ipv6_enabled     = each.value.is_ipv6_enabled
  http_version        = each.value.http_version
  web_acl_id          = each.value.web_acl_id

  origins       = each.value.origins
  origin_groups = each.value.origin_groups

  target_origin_id           = each.value.target_origin_id
  viewer_protocol_policy     = each.value.viewer_protocol_policy
  allowed_methods            = each.value.allowed_methods
  cached_methods             = each.value.cached_methods
  compress                   = each.value.compress
  cache_policy_id            = each.value.cache_policy_id
  origin_request_policy_id   = each.value.origin_request_policy_id
  response_headers_policy_id = each.value.response_headers_policy_id
  field_level_encryption_id  = each.value.field_level_encryption_id
  realtime_log_config_arn    = each.value.realtime_log_config_arn
  ordered_cache_behaviors    = each.value.ordered_cache_behaviors

  use_default_certificate  = each.value.use_default_certificate
  acm_certificate_arn      = each.value.acm_certificate_arn
  ssl_support_method       = each.value.ssl_support_method
  minimum_protocol_version = each.value.minimum_protocol_version

  geo_restriction_type      = each.value.geo_restriction_type
  geo_restriction_locations = each.value.geo_restriction_locations

  enable_logging          = each.value.enable_logging
  logging_bucket          = each.value.logging_bucket
  logging_prefix          = each.value.logging_prefix
  logging_include_cookies = each.value.logging_include_cookies

  custom_error_responses = each.value.custom_error_responses

  tags = each.value.tags
}
