# AWS Route 53 Hosted Zone Root Module

This root module manages Amazon Route 53 hosted zones via Sela Craft dynamic UI.

## Usage

```hcl
module "route53_zone" {
  source = "./modules/aws/route53-zone"

  region = "us-east-1"

  route53_zone = {
    "example.com" = {
      name    = "example.com"
      comment = "Primary public zone"
      tags = {
        Environment = "production"
      }
    }
  }
}
```
