# AWS IAM Role Terraform Module

This module creates and manages an AWS Identity and Access Management (IAM) Role with customizable trust policies, managed policy ARNs, inline policies, session durations, and permission boundaries.

## Features

- **Flexible Naming**: Supports explicit `name` or automated prefix-based generation using `name_prefix`.
- **Default Trust Policy**: Pre-configured with a secure default EC2 trust policy if none is provided.
- **Customizable Trust Policy**: Accepts any JSON trust policy document via `assume_role_policy`.
- **Session Configuration**: Configurable `max_session_duration` with built-in validation (1 hour to 12 hours).
- **Policy Attachments**: Supports exclusive managed policy attachments via `managed_policy_arns` and inline policies via dynamic `inline_policy` blocks.
- **Permission Boundaries**: Supports setting `permissions_boundary` for fine-grained IAM governance.
- **Resource Lifecycle**: Configurable `force_detach_policies` for clean teardown without dependency conflicts.
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Basic Usage

```hcl
module "iam_role" {
  source = "../../modules/aws/iam-role"

  name = "app-ec2-role"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Full Configuration (Lambda Execution Role)

```hcl
module "lambda_exec_role" {
  source = "../../modules/aws/iam-role"

  name        = "payment-processor-role"
  path        = "/service-roles/"
  description = "Execution role for Payment Processor Lambda function"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  force_detach_policies = true
  max_session_duration  = 3600
  permissions_boundary  = "arn:aws:iam::123456789012:policy/DeveloperBoundary"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  inline_policy = [
    {
      name = "dynamodb-access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["dynamodb:GetItem", "dynamodb:PutItem"]
            Effect   = "Allow"
            Resource = "arn:aws:iam::123456789012:table/Payments"
          }
        ]
      })
    }
  ]

  tags = {
    Environment = "production"
    Application = "payment-service"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Friendly name of the role. If omitted, Terraform will assign a random, unique name. | `string` | `"iam-role-default"` | no |
| name_prefix | Creates a unique friendly name beginning with the specified prefix. Conflicts with `name`. | `string` | `null` | no |
| assume_role_policy | Policy that grants an entity permission to assume the role. Must be a valid JSON formatted string. | `string` | Standard EC2 assume role policy | no |
| description | Description of the role. | `string` | `"Managed by Terraform"` | no |
| path | Path to the role. Must begin and end with a forward slash (`/`). | `string` | `"/"` | no |
| force_detach_policies | Whether to force detaching any policies the role has before destroying it. | `bool` | `false` | no |
| max_session_duration | Maximum session duration (in seconds) for the role (3600 to 43200). | `number` | `3600` | no |
| permissions_boundary | ARN of the policy used to set the permissions boundary for the role. | `string` | `null` | no |
| managed_policy_arns | List of exclusive IAM managed policy ARNs to attach to the IAM role. | `list(string)` | `[]` | no |
| inline_policy | Configuration block defining exclusive IAM inline policies associated with the IAM role. | `list(object({ name = string, policy = string }))` | `[]` | no |
| tags | A map of tags to assign to the role. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The name of the IAM role. |
| arn | The Amazon Resource Name (ARN) specifying the IAM role. |
| name | The name of the IAM role. |
| unique_id | Stable and unique string identifying the IAM role. |
| create_date | Creation date of the IAM role in RFC 3339 format. |
| tags_all | A map of tags assigned to the resource, including those inherited from provider default_tags. |
