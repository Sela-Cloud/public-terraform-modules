# AWS IAM User Root Module

This is the Sela Craft frontend root module for deploying one or more AWS IAM Users. It wraps the [`modules/aws/iam-user`](../../../../modules/aws/iam-user) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/iam-user (Root Wrapper Module)
  │ (for_each = var.iam_user)
  ▼
modules/aws/iam-user (Child Module)
  └── aws_iam_user
```

## Quick Start

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review execution plan:
   ```bash
   terraform plan
   ```

4. Apply changes:
   ```bash
   terraform apply
   ```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `region` | The AWS region where resources will be provisioned | `string` | `"us-east-1"` | yes |
| `iam_user` | Map of AWS IAM User configurations to deploy, keyed by username | `map(object({...}))` | Sample default IAM User | no |

### User Configuration Object Schema (`iam_user`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"iam-user-default"` | The user's name (1 to 64 alphanumeric characters and symbols `+=,.@_-`). |
| `path` | `string` | `"/"` | Path in which to create the user (must begin and end with `/`). |
| `permissions_boundary` | `string` | `null` | The ARN of the policy that sets the permissions boundary for the user. |
| `tags` | `map(string)` | `{}` | Key-value tags assigned to the IAM user. |

## Outputs

| Name | Description |
|------|-------------|
| `iam_user` | Map of created IAM Users and their attributes (id, arn, name, unique_id, tags_all, etc.) |
