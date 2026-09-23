# AWS VPC Root Module

This is the Sela Craft frontend root module for deploying one or more AWS Virtual Private Clouds (VPCs). It wraps the [`modules/aws/vpc`](../../../../modules/aws/vpc) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/vpc (Root Wrapper Module)
  │ (for_each = var.vpc)
  ▼
modules/aws/vpc (Child Module)
  └── aws_vpc
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
| `vpc` | Map of VPC configurations to deploy, keyed by VPC name | `map(object({...}))` | Sample default VPC | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc` | Map of created VPCs and their detailed attributes (id, arn, cidr_block, main_route_table_id, default_security_group_id, etc.) |
