# AWS IAM Policy Terraform Module

This module provisions an AWS Identity and Access Management (IAM) Managed Policy with configurable policy documents, paths, name prefixes, creation delays, and tags.

## Features

- **JSON Policy Validation**: Validates that the provided policy document is a valid JSON formatted string.
- **Custom Path Hierarchy**: Organize IAM policies within organizational paths (e.g., `/engineering/`, `/security/`).
- **Flexible Naming**: Supports explicit policy names or automated unique naming via `name_prefix`.
- **Latency Consistency Handling**: Optional creation delay (`delay_after_policy_creation_in_ms`) for high-latency environments.
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Basic Usage

```hcl
module "iam_policy" {
  source = "../../modules/aws/iam-policy"

  name        = "s3-read-only"
  description = "Allows read-only access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:Get*", "s3:List*"]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Usage with Name Prefix and Custom Path

```hcl
module "dynamodb_policy" {
  source = "../../modules/aws/iam-policy"

  name_prefix = "dynamodb-app-"
  path        = "/app-permissions/"
  description = "DynamoDB read/write access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = "arn:aws:dynamodb:*:*:table/app-*"
      }
    ]
  })
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
| name | Friendly name of the policy (1 to 128 characters, alphanumeric and `+=,.@_-`). Conflicts with `name_prefix`. | `string` | `"iam-policy-default"` | no |
| name_prefix | Creates a unique name beginning with the specified prefix. Conflicts with `name`. | `string` | `null` | no |
| description | Description of the IAM policy. | `string` | `"Managed by Terraform"` | no |
| path | Path in which to create the policy. Must begin and end with `/`. | `string` | `"/"` | no |
| policy | The policy document as a valid JSON formatted string. | `string` | CloudWatch Logs access policy | no |
| delay_after_policy_creation_in_ms | Number of milliseconds to wait between creating the policy and setting its version as default. | `number` | `null` | no |
| tags | A map of tags to assign to the policy. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The policy's ID (ARN). |
| arn | The Amazon Resource Name (ARN) assigned by AWS for this policy. |
| name | The name of the policy. |
| description | The description of the policy. |
| path | The path of the policy. |
| policy | The policy document. |
| policy_id | The policy's unique ID. |
| attachment_count | The number of entities (users, groups, and roles) that the policy is attached to. |
| tags_all | A map of tags assigned to the resource, including those inherited from provider default_tags. |
