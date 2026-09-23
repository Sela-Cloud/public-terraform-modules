# AWS IAM Group Root Module

This is the Sela Craft frontend root module for deploying one or more AWS IAM Groups. It wraps the [`modules/aws/iam-group`](../../../../modules/aws/iam-group) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/iam-group (Root Wrapper Module)
  │ (for_each = var.iam_group)
  ▼
modules/aws/iam-group (Child Module)
  ├── aws_iam_group
  └── aws_iam_group_policy_attachment (optional)
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
| `iam_group` | Map of AWS IAM Group configurations to deploy, keyed by group name | `map(object({...}))` | Sample default IAM Group | no |

### Group Configuration Object Schema (`iam_group`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"iam-group-default"` | The group's name (1 to 128 alphanumeric characters and symbols `+=,.@_-`). |
| `path` | `string` | `"/"` | Path in which to create the group (must begin and end with `/`). |
| `managed_policy_arns` | `list(string)` | `[]` | List of AWS managed or customer managed policy ARNs to attach to the group. |

## Outputs

| Name | Description |
|------|-------------|
| `iam_group` | Map of created IAM Groups and their attributes (`id`, `arn`, `name`, `unique_id`, `policy_attachments`). |
