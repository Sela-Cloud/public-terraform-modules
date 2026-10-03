# AWS Application Load Balancer Frontend Module

This frontend module wraps the core AWS Application Load Balancer module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

## Usage

```hcl
module "application_load_balancer" {
  source = "./frontend/modules/aws/application-load-balancer"

  region = "us-east-1"

  application_load_balancer = {
    "web-alb" = {
      name                  = "web-alb"
      internal              = false
      vpc_id                = "vpc-0123456789abcdef0"
      subnets               = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
      create_security_group = true

      target_groups = {
        "app" = {
          name             = "web-alb-app-tg"
          port             = 80
          protocol         = "HTTP"
          protocol_version = "HTTP1"
          target_type      = "instance"
          health_check = {
            enabled             = true
            path                = "/healthz"
            protocol            = "HTTP"
            interval            = 30
            timeout             = 5
            healthy_threshold   = 3
            unhealthy_threshold = 3
            matcher             = "200"
          }
        }
      }

      listeners = {
        "http" = {
          port                = 80
          protocol            = "HTTP"
          default_action_type = "forward"
          target_group_key    = "app"
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
