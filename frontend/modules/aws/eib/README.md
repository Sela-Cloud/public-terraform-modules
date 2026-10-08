# AWS EC2 Image Builder Root Module

This root module manages Amazon EC2 Image Builder pipelines, recipes, and infrastructure configurations via Sela Craft dynamic UI.

## Usage

```hcl
module "eib" {
  source = "./modules/aws/eib"

  region = "us-east-1"

  eib = {
    "golden-image-pipeline" = {
      name                  = "golden-image-pipeline"
      parent_image          = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
      instance_profile_name = "EC2ImageBuilderInstanceProfile"
      instance_types        = ["t3.medium"]
      tags = {
        Environment = "production"
      }
    }
  }
}
```
