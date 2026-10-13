# AWS CloudFront Distribution Terraform Module

This module provisions an Amazon CloudFront distribution in front of one or more origins (S3
buckets or custom origins such as a load balancer), with origin failover groups, path-based cache
behaviors, custom SSL certificates, geo-restriction, access logging, and custom error pages.

## Usage

### S3 origin with the default CloudFront certificate

```hcl
module "cdn" {
  source = "../../modules/aws/cloudfront"

  origins = [
    {
      origin_id                = "s3-site"
      domain_name               = "my-site.s3.amazonaws.com"
      is_s3_origin              = true
      origin_access_control_id  = aws_cloudfront_origin_access_control.this.id
    }
  ]
  target_origin_id = "s3-site"

  tags = {
    Environment = "production"
  }
}
```

### Custom origin with a custom certificate and aliases

```hcl
module "cdn" {
  source = "../../modules/aws/cloudfront"

  aliases = ["www.example.com"]

  origins = [
    {
      origin_id              = "alb"
      domain_name             = "my-alb-123456.us-east-1.elb.amazonaws.com"
      origin_protocol_policy = "https-only"
    }
  ]
  target_origin_id = "alb"

  use_default_certificate = false
  acm_certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123" # must be us-east-1
}
```

## Inputs

The most commonly used inputs. See `variables.tf` for the complete set, including origin
failover groups (`origin_groups`), path-pattern cache behaviors (`ordered_cache_behaviors`),
geo-restriction, access logging, and custom error responses.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `origins` | Origins the distribution can pull content from. At least one is required | `list(object)` | n/a | yes |
| `target_origin_id` | `origin_id` of the origin (or `origin_group_id` of an origin group) the default cache behavior routes to | `string` | n/a | yes |
| `origin_groups` | Origin failover groups, each pairing a primary and secondary origin | `list(object)` | `[]` | no |
| `enabled` | Whether the distribution is enabled | `bool` | `true` | no |
| `aliases` | Alternate domain names (CNAMEs) for the distribution | `list(string)` | `[]` | no |
| `price_class` | Edge location price class | `string` | `"PriceClass_All"` | no |
| `viewer_protocol_policy` | Viewer protocol policy for the default cache behavior | `string` | `"redirect-to-https"` | no |
| `cache_policy_id` | Managed or custom cache policy ID for the default cache behavior | `string` | CachingOptimized | no |
| `ordered_cache_behaviors` | Path-pattern cache behaviors, evaluated in order before the default behavior | `list(object)` | `[]` | no |
| `use_default_certificate` | Use the CloudFront default certificate instead of a custom one | `bool` | `true` | no |
| `acm_certificate_arn` | ACM certificate ARN when not using the default certificate. Must be in us-east-1 | `string` | `null` | no |
| `geo_restriction_type` | `none`, `whitelist`, or `blacklist` | `string` | `"none"` | no |
| `enable_logging` | Enable standard access logging to an S3 bucket | `bool` | `false` | no |
| `custom_error_responses` | Custom error page overrides | `list(object)` | `[]` | no |
| `tags` | Tags assigned to the distribution | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The distribution's identifier |
| `arn` | The ARN of the distribution |
| `domain_name` | The distribution's CloudFront domain name (`d111111abcdef8.cloudfront.net`) |
| `hosted_zone_id` | The CloudFront Route 53 zone ID, used when aliasing a Route 53 record to this distribution |
| `status` | Current status of the distribution |
| `etag` | Current version of the distribution's configuration |
