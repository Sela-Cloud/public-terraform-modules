# AWS Auto Scaling Group Root Module

This root module manages Amazon EC2 Auto Scaling Groups via Sela Craft dynamic UI.

## Usage

```hcl
module "asg" {
  source = "./modules/aws/asg"

  region = "us-east-1"

  asg = {
    "web-asg" = {
      hostname          = "web"
      subnet_ids        = ["subnet-0123456789abcdef0"]
      instance_template = "lt-0123456789abcdef0"
      min_size          = 2
      max_size          = 10
      tags = {
        Environment = "production"
      }
    }
  }
}
```
