# AWS Launch Template Root Module

This root module manages Amazon EC2 Launch Templates via Sela Craft dynamic UI.

## Usage

```hcl
module "lt" {
  source = "./modules/aws/lt"

  region = "us-east-1"

  lt = {
    "web-launch-template" = {
      name          = "web-launch-template"
      image_id      = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.micro"
      key_name      = "my-key"
      tags = {
        Environment = "production"
      }
    }
  }
}
```
