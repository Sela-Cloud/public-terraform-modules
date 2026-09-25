# AWS Network ACL Root Module

This is the Sela Craft frontend root module for provisioning and managing one or more AWS Network Access Control Lists (NACLs). It wraps the [`modules/aws/network-acl`](../../../../modules/aws/network-acl) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/network-acl (Root Wrapper Module)
  │ (for_each = var.network_acl)
  ▼
modules/aws/network-acl (Child Module)
  └── aws_network_acl
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
| `network_acl` | Map of AWS Network ACL configurations to deploy, keyed by network ACL name | `map(object({...}))` | `{}` | no |

### Network ACL Configuration Object Schema (`network_acl`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"network-acl-default"` | Name applied to the Network ACL as an identifier and 'Name' tag. |
| `vpc_id` | `string` | - | The ID of the associated VPC. |
| `subnet_ids` | `list(string)` | `[]` | List of Subnet IDs to associate with this Network ACL. |
| `ingress` | `list(object)` | `[]` | Inbound traffic filtering rules. |
| `egress` | `list(object)` | `[]` | Outbound traffic filtering rules. |
| `tags` | `map(string)` | `{}` | Key-value tags assigned to the Network ACL. |

## Outputs

| Name | Description |
|------|-------------|
| `network_acl` | Map of created Network ACL resources and their attributes (`id`, `arn`, `owner_id`, `vpc_id`, `subnet_ids`, `ingress`, `egress`, `tags_all`). |
