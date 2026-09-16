# AWS Subnet Root Module

This is the Sela Craft frontend root module for deploying one or more Amazon Virtual Private Cloud (VPC) Subnets. It wraps the [`modules/aws/subnet`](../../../../modules/aws/subnet) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/subnet (Root Wrapper Module)
  │ (for_each = var.subnet)
  ▼
modules/aws/subnet (Child Module)
  └── aws_subnet
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
| `subnet` | Map of Subnet configurations to deploy, keyed by subnet name | `map(object({...}))` | Sample default Subnet | no |

## Outputs

| Name | Description |
|------|-------------|
| `subnet` | Map of created Subnets and their detailed attributes (id, arn, vpc_id, cidr_block, availability_zone, tags_all, etc.) |
