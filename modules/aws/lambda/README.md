# AWS Lambda Terraform Module

A production-ready Terraform module to provision and manage an [AWS Lambda Function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) and its associated resources in accordance with the official Terraform AWS Provider documentation.

## Features

- **Full Resource & Argument Coverage**: Implements all official arguments of `aws_lambda_function`, including environment variables, VPC integration, ephemeral storage (`/tmp`), dead-letter queues, file systems (EFS), container image overrides, advanced logging, SnapStart, and X-Ray tracing.
- **Automated Placeholder Bootstrap**: Generates an initial inline bootstrap package (`index.js`) so the function can be created and planned immediately without requiring external code files upfront.
- **Dedicated Execution Role**: Automatically provisions an IAM execution role with `AWSLambdaBasicExecutionRole` and `AWSLambdaVPCAccessExecutionRole` (if VPC is configured), with support for custom managed and inline policies.
- **Dedicated CloudWatch Log Group**: Manages `/aws/lambda/<function_name>` with configurable retention days, KMS encryption, and log class.
- **Lambda Function URL**: Supports HTTPS endpoints with CORS, authentication modes (`NONE`, `AWS_IAM`), and invocation modes (`BUFFERED`, `RESPONSE_STREAM`).
- **Resource-Based Permissions**: Supports invoking permissions for API Gateway, S3, EventBridge, SNS, SQS, etc.
- **Aliases & Provisioned Concurrency**: Create aliases with traffic routing weights and pre-warmed execution environments.
- **Event Source Mappings**: Integrated support for triggering Lambda from SQS, DynamoDB Streams, Kinesis, Kafka, and DocumentDB.
- **Lambda Layers & Code Signing**: Create and attach Lambda Layers and configure Code Signing verification.

## Architecture & Resources

```
                    ┌──────────────────────────────────────────────┐
                    │               AWS Lambda Function            │
                    │         (Runtime, Memory, Architecture)      │
                    └───────┬──────────────┬──────────────┬────────┘
                            │              │              │
             ┌──────────────▼────┐  ┌──────▼──────┐  ┌────▼─────────────┐
             │ Function URL      │  │ Permissions │  │ CloudWatch Logs  │
             │ (HTTPS Invocation)│  │ (S3 / APIGW)│  │ (/aws/lambda/..) │
             └───────────────────┘  └─────────────┘  └──────────────────┘
```

## Usage Examples

### 1. Basic Function with Function URL (Direct HTTP Invocation)

```hcl
module "lambda" {
  source = "../../modules/aws/lambda"

  function_name = "hello-world-api"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  architectures = ["arm64"]
  memory_size   = 256
  timeout       = 10

  create_function_url    = true
  function_url_auth_type = "NONE"

  environment_variables = {
    ENVIRONMENT = "production"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. VPC-Enabled Lambda with Custom Code & CloudWatch Logging

```hcl
module "vpc_lambda" {
  source = "../../modules/aws/lambda"

  function_name = "data-processor"
  runtime       = "python3.12"
  handler       = "app.lambda_handler"
  filename      = "${path.module}/build/app.zip"

  # VPC Configuration
  vpc_subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  vpc_security_group_ids = ["sg-0123456789abcdef0"]

  # Ephemeral storage and tracing
  ephemeral_storage_size = 1024
  tracing_mode           = "Active"

  # 30-day log retention
  create_log_group      = true
  log_retention_in_days = 30

  # API Gateway invocation permission
  lambda_permissions = {
    apigateway = {
      principal  = "apigateway.amazonaws.com"
      source_arn = "arn:aws:execute-api:us-east-1:123456789012:api-id/*/*/*"
    }
  }

  tags = {
    Environment = "staging"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `function_name` | Unique name for the Lambda Function | `string` | n/a | yes |
| `description` | Description of what your Lambda Function does | `string` | `null` | no |
| `runtime` | Identifier of the function runtime | `string` | `"nodejs20.x"` | no |
| `handler` | Function entrypoint in code | `string` | `"index.handler"` | no |
| `architectures` | Instruction set architecture (`x86_64` or `arm64`) | `list(string)` | `["x86_64"]` | no |
| `memory_size` | Memory in MB (128 to 10240) | `number` | `128` | no |
| `timeout` | Timeout in seconds (1 to 900) | `number` | `3` | no |
| `filename` | Path to local deployment zip | `string` | `null` | no |
| `s3_bucket` | S3 bucket containing deployment zip | `string` | `null` | no |
| `image_uri` | ECR container image URI | `string` | `null` | no |
| `environment_variables` | Map of environment variables | `map(string)` | `{}` | no |
| `vpc_subnet_ids` | List of VPC Subnet IDs | `list(string)` | `[]` | no |
| `vpc_security_group_ids` | List of VPC Security Group IDs | `list(string)` | `[]` | no |
| `create_function_url` | Whether to create an HTTPS Function URL | `bool` | `false` | no |
| `create_role` | Whether to create dedicated IAM execution role | `bool` | `true` | no |
| `create_log_group` | Whether to create dedicated CloudWatch Log Group | `bool` | `true` | no |
| `tags` | Map of resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Name of the Lambda Function |
| `function_arn` | ARN of the Lambda Function |
| `invoke_arn` | ARN for invocation from API Gateway |
| `role_arn` | ARN of the IAM Execution Role |
| `log_group_arn` | ARN of the CloudWatch Log Group |
| `function_url` | HTTP(S) endpoint URL (if enabled) |
