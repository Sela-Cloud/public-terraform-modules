# AWS IAM Policy Root Module

This is the Sela Craft frontend root module for deploying one or more AWS IAM Managed Policies. It wraps the [`modules/aws/iam-policy`](../../../../modules/aws/iam-policy) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/iam-policy (Root Wrapper Module)
  │ (for_each = var.iam_policy)
  ▼
modules/aws/iam-policy (Child Module)
  └── aws_iam_policy
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
| `iam_policy` | Map of AWS IAM Policy configurations to deploy, keyed by policy name | `map(object({...}))` | Sample default IAM Policy | no |

### Policy Configuration Object Schema (`iam_policy`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"iam-policy-default"` | Friendly name of the policy (1 to 128 alphanumeric characters and symbols `+=,.@_-`). Conflicts with `name_prefix`. |
| `name_prefix` | `string` | `null` | Creates a unique friendly name beginning with the specified prefix. Conflicts with `name`. |
| `description` | `string` | `"Managed by Terraform"` | Description of the policy's purpose and usage. |
| `path` | `string` | `"/"` | Path in which to create the policy (must begin and end with `/`). |
| `policy` | `string` | Default CloudWatch Logs access document | Valid JSON formatted policy document specifying permissions. |
| `delay_after_policy_creation_in_ms` | `number` | `null` | Optional delay in milliseconds after policy creation. |
| `tags` | `map(string)` | `{}` | Key-value tags assigned to the IAM policy. |

## Outputs

| Name | Description |
|------|-------------|
| `iam_policy` | Map of created IAM Policies and their attributes (`id`, `arn`, `name`, `description`, `path`, `policy`, `policy_id`, `attachment_count`, `tags_all`). |
