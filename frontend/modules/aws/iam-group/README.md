# AWS IAM Group Terraform Module

This module provisions an AWS Identity and Access Management (IAM) Group with configurable paths and managed policy attachments.

## Features

- **Custom Path Hierarchy**: Organize IAM groups within organizational paths (e.g., `/engineering/`, `/administrators/`).
- **Name Validation**: Enforces AWS naming conventions for IAM group names (1 to 128 alphanumeric characters and symbols `+=,.@_-`).
- **Policy Attachments**: Optional attachment of AWS managed or custom IAM policy ARNs directly to the group.

## Usage

### Basic Usage

```hcl
module "iam_group" {
  source = "../../modules/aws/iam-group"

  name = "developers"
}
```

### Full Configuration (Group with Custom Path and Attached Policies)

```hcl
module "admin_group" {
  source = "../../modules/aws/iam-group"

  name = "administrators"
  path = "/operations/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
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
| name | The group's name (1 to 128 alphanumeric characters and symbols `+=,.@_-`). | `string` | `"iam-group-default"` | no |
| path | Path in which to create the group. Must begin and end with `/`. | `string` | `"/"` | no |
| managed_policy_arns | List of IAM policy ARNs to attach to the IAM group. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The group's name. |
| arn | The Amazon Resource Name (ARN) assigned by AWS for this group. |
| name | The group's name. |
| unique_id | The unique ID assigned by AWS for this group. |
| policy_attachments | A list of policy ARNs attached to the IAM group. |
