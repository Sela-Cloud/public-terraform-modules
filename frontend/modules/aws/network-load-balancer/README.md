# AWS Network Load Balancer Frontend Module

This frontend module wraps the core AWS Network Load Balancer module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

## Usage

```hcl
module "network_load_balancer" {
  source = "./frontend/modules/aws/network-load-balancer"

  region = "us-east-1"

  network_load_balancer = {
    "prod-nlb" = {
      name                             = "prod-nlb"
      internal                         = false
      vpc_id                           = "vpc-0123456789abcdef0"
      subnets                          = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
      enable_cross_zone_load_balancing = true

      target_groups = {
        "tcp-service" = {
          name                 = "prod-nlb-tcp-tg"
          port                 = 80
          protocol             = "TCP"
          target_type          = "instance"
          deregistration_delay = 300
          preserve_client_ip   = true
          health_check = {
            enabled  = true
            protocol = "TCP"
            interval = 10
            timeout  = 10
          }
        }
      }

      listeners = {
        "tcp-80" = {
          port             = 80
          protocol         = "TCP"
          target_group_key = "tcp-service"
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
