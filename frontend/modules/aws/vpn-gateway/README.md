# AWS VPN Gateway Frontend Module

This frontend module wraps the core AWS VPN Gateway module for the Sela Craft platform, supporting
dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one Virtual Private Gateway, attached directly to a VPC, with
optional route propagation for dynamic (BGP) routing.

## Usage

```hcl
module "vpn_gateway" {
  source = "./frontend/modules/aws/vpn-gateway"

  region = "us-east-1"

  vpn_gateway = {
    "prod-vgw" = {
      vpc_id = "vpc-0123456789abcdef0"

      route_table_ids = ["rtb-0123456789abcdef0"]

      tags = {
        Environment = "production"
      }
    }
  }
}
```
