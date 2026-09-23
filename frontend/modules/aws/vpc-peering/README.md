# AWS VPC Peering Frontend Module

This frontend module wraps the core AWS VPC Peering module for the Sela Craft platform, supporting map variables and `ui-metadata.json`.

## Usage

```hcl
module "vpc_peerings" {
  source = "./frontend/modules/aws/vpc-peering"

  region = "us-east-1"

  vpc_peering = {
    "peering-conn-1" = {
      name                             = "peering-conn-1"
      vpc_id                           = "vpc-0123456789abcdef0"
      peer_vpc_id                      = "vpc-0fedcba9876543210"
      auto_accept                      = true
      allow_remote_vpc_dns_resolution = true
    }
  }
}
```
