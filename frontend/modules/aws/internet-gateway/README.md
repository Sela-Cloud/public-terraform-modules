# AWS Internet Gateway Frontend Module

This frontend module wraps the core AWS Internet Gateway module for the Sela Craft platform,
supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one Internet Gateway, attached directly to a VPC, and optionally an
Egress-Only Internet Gateway for the same VPC.

## Usage

```hcl
module "internet_gateway" {
  source = "./frontend/modules/aws/internet-gateway"

  region = "us-east-1"

  internet_gateway = {
    "prod-igw" = {
      vpc_id = "vpc-0123456789abcdef0"

      tags = {
        Environment = "production"
      }
    }
  }
}
```
