# AWS Route 53 Record Terraform Module

This module creates a single DNS record in an existing Route 53 hosted zone, supporting standard
records, alias records, and every Route 53 routing policy (simple, weighted, latency, failover,
geolocation, geoproximity, CIDR, and multivalue answer).

## Usage

### Simple A record

```hcl
module "record" {
  source = "../../modules/aws/route53-record"

  zone_id = "Z1D633PJN98FT9"
  name    = "www.example.com"
  type    = "A"
  records = ["203.0.113.10"]
  ttl     = 300
}
```

### Alias to a CloudFront distribution

```hcl
module "record" {
  source = "../../modules/aws/route53-record"

  zone_id   = "Z1D633PJN98FT9"
  name      = "www.example.com"
  type      = "A"
  is_alias  = true
  alias_name    = "d111111abcdef8.cloudfront.net"
  alias_zone_id = "Z2FDTNDATAQYW2"
}
```

### Weighted routing

```hcl
module "record" {
  source = "../../modules/aws/route53-record"

  zone_id             = "Z1D633PJN98FT9"
  name                = "api.example.com"
  type                = "A"
  records             = ["203.0.113.20"]
  routing_policy_type = "WEIGHTED"
  set_identifier      = "blue"
  weighted_weight     = 90
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `zone_id` | Target hosted zone ID | `string` | n/a | yes |
| `name` | Record name | `string` | n/a | yes |
| `type` | DNS record type | `string` | n/a | yes |
| `is_alias` | Whether this is an alias record | `bool` | `false` | no |
| `alias_name` | Alias target's DNS name. Required if `is_alias` | `string` | `null` | no |
| `alias_zone_id` | Alias target's own hosted zone ID. Required if `is_alias` | `string` | `null` | no |
| `alias_evaluate_target_health` | Evaluate the alias target's health | `bool` | `false` | no |
| `ttl` | TTL in seconds. Ignored if `is_alias` | `number` | `300` | no |
| `records` | Record values. Ignored if `is_alias` | `list(string)` | `[]` | no |
| `routing_policy_type` | One of SIMPLE, WEIGHTED, LATENCY, FAILOVER, GEOLOCATION, GEOPROXIMITY, CIDR, MULTIVALUE | `string` | `"SIMPLE"` | no |
| `set_identifier` | Distinguishes this record from others sharing name/type/policy. Required for non-SIMPLE policies | `string` | `null` | no |
| `health_check_id` | Route 53 health check ID | `string` | `null` | no |
| `weighted_weight` | Weight for WEIGHTED routing | `number` | `null` | no |
| `latency_region` | AWS region for LATENCY routing | `string` | `null` | no |
| `failover_type` | `PRIMARY` or `SECONDARY` for FAILOVER routing | `string` | `null` | no |
| `geolocation_continent` / `geolocation_country` / `geolocation_subdivision` | Location to match for GEOLOCATION routing. Subdivision requires country `US` | `string` | `null` | no |
| `geoproximity_aws_region` / `geoproximity_local_zone_group` / `geoproximity_latitude` / `geoproximity_longitude` / `geoproximity_bias` | Bias origin and bias for GEOPROXIMITY routing | various | `null` | no |
| `cidr_collection_id` / `cidr_location_name` | Target for CIDR routing | `string` | `null` | no |
| `allow_overwrite` | Allow overwriting an existing record of the same name/type | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The record's ID |
| `fqdn` | The fully qualified domain name of the record |
