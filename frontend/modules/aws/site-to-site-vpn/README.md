# AWS Site-to-Site VPN Frontend Module

This frontend module wraps the core AWS Site-to-Site VPN module for the Sela Craft platform,
supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one VPN Connection -- either to a Virtual Private Gateway or a
Transit Gateway -- plus a Customer Gateway (created inline, or an existing one referenced by ID).

## Usage

```hcl
module "site_to_site_vpn" {
  source = "./frontend/modules/aws/site-to-site-vpn"

  region = "us-east-1"

  site_to_site_vpn = {
    "prod-s2s-vpn" = {
      customer_gateway_ip_address = "203.0.113.1"
      customer_gateway_bgp_asn    = "65000"

      vpn_gateway_id = "vgw-0123456789abcdef0"

      tunnel1 = {
        preshared_key = "SuperSecretKey123"
      }
      tunnel2 = {
        preshared_key = "AnotherSecretKey456"
      }

      tags = {
        Environment = "production"
      }
    }
  }
}
```
