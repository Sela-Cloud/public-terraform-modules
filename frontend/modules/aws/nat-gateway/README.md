# AWS NAT Gateway Root Module

This is the Sela Craft frontend root module for deploying one or more Amazon Virtual Private Cloud (VPC) NAT Gateways. It wraps the [`modules/aws/nat-gateway`](../../../../modules/aws/nat-gateway) child module using Terraform's `for_each` meta-argument.

## Architecture

```
frontend/modules/aws/nat-gateway (Root Wrapper Module)
  │ (for_each = var.nat_gateway)
  ▼
modules/aws/nat-gateway (Child Module)
  └── aws_nat_gateway
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
| `nat_gateway` | Map of NAT Gateway configurations to deploy, keyed by NAT gateway name | `map(object({...}))` | Sample default NAT Gateway | no |

## Outputs

| Name | Description |
|------|-------------|
| `nat_gateway` | Map of created NAT Gateways and their detailed attributes (id, allocation_id, association_id, network_interface_id, public_ip, route_table_id, auto_provision_zones, auto_scaling_ips, regional_nat_gateway_address, tags_all) |
