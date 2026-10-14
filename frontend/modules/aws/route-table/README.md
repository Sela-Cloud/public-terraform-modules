# AWS Route Table Frontend Module

This frontend module wraps the core AWS Route Table module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one route table, with its own subnet or gateway association and its own list of routes.

## Usage

```hcl
module "route_table" {
  source = "./frontend/modules/aws/route-table"

  region = "us-east-1"

  route_table = {
    "prod-public-rt" = {
      vpc_id  = "vpc-0123456789abcdef0"
      subnets = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

      routes = [
        {
          key                     = "default_ipv4"
          destination_cidr_block = "0.0.0.0/0"
          gateway_id              = "igw-0123456789abcdef0"
        }
      ]

      tags = {
        Tier = "public"
      }
    }
  }
}
```
