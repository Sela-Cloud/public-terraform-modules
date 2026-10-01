# AWS IAM User Terraform Module

This module provisions an AWS Identity and Access Management (IAM) User with configurable paths, permissions boundaries, and tags.

## Features

- **Custom Path Hierarchy**: Organize IAM users within organizational paths (e.g., `/engineering/`, `/service-accounts/`).
- **Permissions Boundary Enforcement**: Support for attaching a permissions boundary policy ARN to restrict maximum allowable permissions.
- **Name Validation**: Enforces AWS naming conventions for IAM usernames (1 to 64 alphanumeric characters and symbols `+=,.@_-`).
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Basic Usage

```hcl
module "iam_user" {
  source = "../../modules/aws/iam-user"

  name = "john.doe"

  tags = {
    Department  = "Engineering"
    Environment = "production"
  }
}
```

### Full Configuration (Service Account User with Permissions Boundary)

```hcl
module "service_user" {
  source = "../../modules/aws/iam-user"

  name                 = "cicd-deployer"
  path                 = "/automation/"
  permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"

  tags = {
    Team        = "DevOps"
    Purpose     = "CI/CD Deployment"
    Environment = "production"
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
| name | The user's name (1 to 64 alphanumeric chars and `+=,.@_-`). | `string` | `"iam-user-default"` | no |
| path | Path in which to create the user. Must begin and end with `/`. | `string` | `"/"` | no |
| permissions_boundary | The ARN of the policy that is used to set the permissions boundary for the user. | `string` | `null` | no |
| tags | A map of tags to assign to the user. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The user's name. |
| arn | The Amazon Resource Name (ARN) assigned by AWS for this user. |
| name | The user's name. |
| unique_id | The unique ID assigned by AWS for this user. |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider default_tags. |
