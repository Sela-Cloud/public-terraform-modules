# AWS IAM Role Root Module

This is the Sela Craft frontend root module for deploying one or more AWS IAM Roles. It wraps the [`modules/aws/iam-role`](../../../../modules/aws/iam-role) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/iam-role (Root Wrapper Module)
  │ (for_each = var.iam_role)
  ▼
modules/aws/iam-role (Child Module)
  └── aws_iam_role
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
| `iam_role` | Map of AWS IAM Role configurations to deploy, keyed by role name | `map(object({...}))` | Sample default IAM Role | no |

### Role Configuration Object Schema (`iam_role`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"iam-role-default"` | Friendly name of the IAM role. Conflicts with `name_prefix`. |
| `name_prefix` | `string` | `null` | Prefix for role name generation. Conflicts with `name`. |
| `assume_role_policy` | `string` | Standard EC2 trust policy | JSON string granting entities permission to assume this role. |
| `description` | `string` | `"Managed by Terraform"` | Description of the role. |
| `path` | `string` | `"/"` | Path to the role (must start and end with `/`). |
| `force_detach_policies` | `bool` | `false` | Whether to force detaching policies before destroying. |
| `max_session_duration` | `number` | `3600` | Max session duration in seconds (3600 to 43200). |
| `permissions_boundary` | `string` | `null` | ARN of permissions boundary policy. |
| `managed_policy_arns` | `list(string)` | `[]` | List of IAM managed policy ARNs to attach. |
| `inline_policy` | `list(object)` | `[]` | List of inline policy objects (`name`, `policy`). |
| `tags` | `map(string)` | `{}` | Key-value tags to assign to the role. |

## Outputs

| Name | Description |
|------|-------------|
| `iam_role` | Map of created IAM Roles and their attributes (id, arn, name, unique_id, create_date, tags_all, etc.) |
