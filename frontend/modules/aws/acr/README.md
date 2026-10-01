# AWS ECR/ACR Repository Frontend Module

This frontend root module wraps the core AWS ECR/ACR repository module for the Sela Craft platform, supporting multi-instance map variables and `ui-metadata.json`.

## Usage

```hcl
module "acr_repositories" {
  source = "./frontend/modules/aws/acr"

  region = "us-east-1"

  acr = {
    "my-app-repo" = {
      name                 = "my-app-repo"
      image_tag_mutability = "IMMUTABLE"
      force_delete         = false
      scan_on_push         = true
      encryption_type      = "AES256"
      kms_key              = null
      tags = {
        Environment = "production"
        Team        = "backend"
      }
    }
  }
}
```
