# Route 53 Record Root Module

This root module manages Amazon Route 53 DNS records via Sela Craft dynamic UI.

## Usage

```hcl
module "route53_record" {
  source = "./modules/aws/route53-record"

  region = "us-east-1"

  route53_record = {
    "www.example.com" = {
      zone_id = "Z1D633PJN98FT9"
      name    = "www.example.com"
      type    = "A"
      records = ["203.0.113.10"]
    }
  }
}
```
