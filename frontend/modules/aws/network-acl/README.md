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
| `ingress` | `list(object)` | `[]` | Inbound traffic filtering rules (see schema below). |
| `egress` | `list(object)` | `[]` | Outbound traffic filtering rules (see schema below). |
| `tags` | `map(string)` | `{}` | Key-value tags assigned to the Network ACL. |

#### Ingress / Egress Rule Object Schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `rule_no` | `number` | - | Rule number for ordering evaluation (1 to 32766). Lower numbers evaluated first. |
| `action` | `string` | `"allow"` | Action to take: `"allow"` or `"deny"`. |
| `protocol` | `string` | `"-1"` | Protocol to match: `"tcp"`, `"udp"`, `"icmp"`, or `"-1"` (all). |
| `from_port` | `number` | `0` | Start of port range (0-65535). Use 0 for all protocols. |
| `to_port` | `number` | `0` | End of port range (0-65535). Use 0 for all protocols. |
| `cidr_block` | `string` | `null` | The IPv4 CIDR block to match (e.g. `0.0.0.0/0`). |
| `ipv6_cidr_block` | `string` | `null` | The IPv6 CIDR block to match (e.g. `::/0`). |
| `icmp_type` | `number` | `null` | The ICMP type code (used when protocol is `"icmp"`). |
| `icmp_code` | `number` | `null` | The ICMP code (used when protocol is `"icmp"`). |

## Outputs

| Name | Description |
|------|-------------|
| `network_acl` | Map of created Network ACL resources and their attributes (`id`, `arn`, `owner_id`, `vpc_id`, `subnet_ids`, `ingress`, `egress`, `tags_all`). |
