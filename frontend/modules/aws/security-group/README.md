# AWS Security Group Frontend Module

This frontend module wraps the core AWS Security Group module for the Sela Craft platform, supporting map variables and `ui-metadata.json`.

## Usage

```hcl
module "security_groups" {
  source = "./frontend/modules/aws/security-group"

  region = "us-east-1"

  security_group = {
    "web-sg" = {
      name        = "web-sg"
      description = "Security group for web instances"
      vpc_id      = "vpc-0123456789abcdef0"
      ingress_rules = [
        {
          description = "Allow HTTPS"
          from_port   = 443
          to_port     = 443
          ip_protocol = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
    }
  }
}
```
