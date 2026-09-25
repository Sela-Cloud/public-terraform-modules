# AWS Elastic IP (EIP) Root Module

This is the Sela Craft frontend root module for provisioning and managing one or more AWS Elastic IP (EIP) resources. It wraps the [`modules/aws/eip`](../../../../modules/aws/eip) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/eip (Root Wrapper Module)
  │ (for_each = var.eip)
  ▼
modules/aws/eip (Child Module)
  └── aws_eip
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
| `eip` | Map of AWS Elastic IP configurations to deploy, keyed by Elastic IP name | `map(object({...}))` | Sample default EIP | no |

### Elastic IP Configuration Object Schema (`eip`)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `"eip-default"` | Name applied to the Elastic IP as an identifier and 'Name' tag. |
| `domain` | `string` | `"vpc"` | Indicates whether this Elastic IP is for use in a VPC (`"vpc"`). |
| `instance` | `string` | `null` | EC2 instance ID to associate with the Elastic IP. Conflicts with `network_interface`. |
| `network_interface` | `string` | `null` | Elastic Network Interface (ENI) ID to associate with. Conflicts with `instance`. |
| `associate_with_private_ip` | `string` | `null` | Primary or secondary private IP address to associate with the Elastic IP address. |
| `public_ipv4_pool` | `string` | `null` | EC2 IPv4 address pool identifier or `"amazon"`. |
| `network_border_group` | `string` | `null` | Location from which the IP address is advertised (AWS Region or Local Zone). |
| `customer_owned_ipv4_pool` | `string` | `null` | ID of a customer-owned address pool for AWS Outposts. |
| `ipam_pool_id` | `string` | `null` | The ID of an IPAM pool which has an Amazon-provided or BYOIP public IPv4 CIDR provisioned to it. |
| `address` | `string` | `null` | IP address from an EC2 BYOIP pool. |
| `tags` | `map(string)` | `{}` | Key-value tags assigned to the Elastic IP. |

## Outputs

| Name | Description |
|------|-------------|
| `eip` | Map of created Elastic IP resources and their attributes (`id`, `allocation_id`, `association_id`, `carrier_ip`, `customer_owned_ip`, `domain`, `instance`, `network_interface`, `private_dns`, `private_ip`, `ptr_record`, `public_dns`, `public_ip`, `tags_all`). |
