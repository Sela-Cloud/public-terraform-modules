# AWS Secrets Manager Root Module

This root module manages Amazon Secrets Manager secrets via Sela Craft dynamic UI.

## Usage

```hcl
module "secret" {
  source = "./modules/aws/secret"

  region = "us-east-1"

  secrets = {
    "prod/app/db-password" = {
      description = "Database password for the production app tier"
      tags = {
        Environment = "production"
      }
    }
  }
}
```
