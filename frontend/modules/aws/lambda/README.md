# AWS Lambda Frontend Module

This frontend module wraps the core AWS Lambda module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one Lambda function, its execution role (optional), log group, triggers, and related resources.

## Usage

```hcl
module "lambda" {
  source = "./frontend/modules/aws/lambda"

  region = "us-east-1"

  lambda = {
    "my-lambda-service" = {
      runtime = "nodejs20.x"
      handler = "index.handler"

      environment_variables = {
        NODE_ENV = "production"
      }

      create_function_url = true

      tags = {
        Environment = "production"
      }
    }
  }
}
```
