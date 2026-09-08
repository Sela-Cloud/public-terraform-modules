# AWS EC2 Instance Root Module

This is the Sela Craft frontend root module for deploying one or more AWS EC2 instances. It wraps the [`modules/aws/ec2-instance`](../../../../modules/aws/ec2-instance) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/ec2-instance (Root Wrapper Module)
  │ (for_each = var.ec2_instance)
  ▼
modules/aws/ec2-instance (Child Module)
  ├── aws_instance
  ├── aws_ebs_volume (optional secondary disks)
  ├── aws_volume_attachment
  ├── aws_eip (optional)
  └── aws_eip_association
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
| `ec2_instance` | Map of EC2 instance configurations to deploy, keyed by instance name | `map(object({...}))` | Sample default instance | no |

## Outputs

| Name | Description |
|------|-------------|
| `ec2_instance` | Map of created EC2 instances and their detailed attributes (id, arn, public_ip, private_ip, eip_public_ip, etc.) |
