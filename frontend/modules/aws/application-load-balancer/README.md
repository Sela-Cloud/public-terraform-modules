# AWS Application Load Balancer Frontend Module

This frontend module wraps the core AWS Application Load Balancer module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one ALB, its optional dedicated security group, target groups, listeners, listener rules, and optional WAF association.

## Usage

```hcl
module "application_load_balancer" {
  source = "./frontend/modules/aws/application-load-balancer"

  region = "us-east-1"

  application_load_balancer = {
    "my-alb" = {
      vpc_id  = "vpc-0123456789abcdef0"
      subnets = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

      create_security_group = true

      target_groups = [
        { key = "web", port = 80 }
      ]

      listeners = [
        { key = "http", port = 80, protocol = "HTTP", target_group_key = "web" }
      ]

      tags = {
        Environment = "production"
      }
    }
  }
}
```
