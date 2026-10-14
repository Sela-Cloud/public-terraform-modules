# AWS Network Load Balancer Frontend Module

This frontend module wraps the core AWS Network Load Balancer module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one NLB, its optional dedicated security group, target groups, and listeners.

## Usage

```hcl
module "network_load_balancer" {
  source = "./frontend/modules/aws/network-load-balancer"

  region = "us-east-1"

  network_load_balancer = {
    "my-nlb" = {
      vpc_id  = "vpc-0123456789abcdef0"
      subnets = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

      target_groups = [
        { key = "tcp-tg", port = 80, protocol = "TCP" }
      ]

      listeners = [
        { key = "tcp", port = 80, protocol = "TCP", target_group_key = "tcp-tg" }
      ]

      tags = {
        Environment = "production"
      }
    }
  }
}
```
