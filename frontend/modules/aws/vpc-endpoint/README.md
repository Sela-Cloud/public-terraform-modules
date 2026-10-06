# AWS VPC Endpoint Frontend Module

This frontend module wraps the core AWS VPC Endpoint module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

## Usage

```hcl
module "vpc_endpoint" {
  source = "./frontend/modules/aws/vpc-endpoint"

  region = "us-east-1"

  vpc_endpoint = {
    "prod-endpoints" = {
      vpc_id                = "vpc-0123456789abcdef0"
      subnet_ids            = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
      route_table_ids       = ["rtb-0123456789abcdef0"]
      create_security_group = true

      endpoints = {
        "s3" = {
          service      = "s3"
          service_type = "Gateway"
        }
        "ssm" = {
          service      = "ssm"
          service_type = "Interface"
        }
        "ecr-api" = {
          service      = "ecr.api"
          service_type = "Interface"
        }
        "ecr-dkr" = {
          service      = "ecr.dkr"
          service_type = "Interface"
        }
      }

      tags = {
        Environment = "production"
        ManagedBy   = "Terraform"
      }
    }
  }
}
```
