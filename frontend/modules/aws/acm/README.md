# AWS ACM Certificate Root Module

This root module manages AWS Certificate Manager (ACM) SSL/TLS certificates via Sela Craft dynamic UI.

## Usage

```hcl
module "acm" {
  source = "./modules/aws/acm"

  region = "us-east-1"

  acm = {
    "api-cert" = {
      name                   = "api-cert"
      domain_name            = "api.example.com"
      validation_method      = "DNS"
      create_route53_records = true
      zone_id                = "Z1234567890ABCDEF"
      validate_certificate   = true
      tags = {
        Environment = "production"
      }
    }
  }
}
```
