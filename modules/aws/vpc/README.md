# AWS VPC Terraform Module

This module provisions an Amazon Virtual Private Cloud (VPC) with configurable IPv4/IPv6 CIDR blocks, DNS settings, tenancy, and Network Address Usage (NAU) metrics.

## Features

- **IPv4 CIDR Support**: Configurable primary IPv4 CIDR block with safe defaults (`10.0.0.0/16`).
- **Tenancy Management**: Supports `default` (shared hardware) and `dedicated` (single-tenant hardware) instance tenancy.
- **DNS Resolution & Hostnames**: Fully configurable flags for DNS resolution support and DNS hostnames.
- **IPv6 Capabilities**: Support for automated Amazon-provided IPv6 CIDR blocks (`/56`) or custom IPv6 CIDR blocks with network border group targeting.
- **NAU Metrics**: Optional enabling of Network Address Usage metrics.
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Basic Usage

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  name       = "my-vpc"
  cidr_block = "10.0.0.0/16"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Full Configuration

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"

  name                                 = "production-vpc"
  cidr_block                           = "10.100.0.0/16"
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = false
  assign_generated_ipv6_cidr_block     = true

  tags = {
    Environment = "production"
    Department  = "PlatformEngineering"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name to be used on all resources as identifier, applied as the 'Name' tag | `string` | `"vpc-default"` | no |
| `cidr_block` | The IPv4 CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `instance_tenancy` | Tenancy option for instances launched into the VPC (`default` or `dedicated`) | `string` | `"default"` | no |
| `enable_dns_support` | Whether to enable DNS support (resolution) in the VPC | `bool` | `true` | no |
| `enable_dns_hostnames` | Whether to enable DNS hostnames in the VPC (requires `enable_dns_support`) | `bool` | `false` | no |
| `enable_network_address_usage_metrics` | Whether to enable Network Address Usage (NAU) metrics for the VPC | `bool` | `false` | no |
| `assign_generated_ipv6_cidr_block` | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length | `bool` | `false` | no |
| `ipv6_cidr_block_network_border_group` | Restricts advertisement of public addresses to specific Network Border Groups | `string` | `null` | no |
| `tags` | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the VPC |
| `arn` | The ARN of the VPC |
| `cidr_block` | The IPv4 CIDR block of the VPC |
| `instance_tenancy` | Tenancy of instances spun up within the VPC |
| `enable_dns_support` | Whether or not the VPC has DNS support |
| `enable_dns_hostnames` | Whether or not the VPC has DNS hostnames support |
| `enable_network_address_usage_metrics` | Whether Network Address Usage metrics are enabled for the VPC |
| `main_route_table_id` | The ID of the main route table associated with this VPC |
| `default_network_acl_id` | The ID of the network ACL created by default on VPC creation |
| `default_security_group_id` | The ID of the security group created by default on VPC creation |
| `default_route_table_id` | The ID of the route table created by default on VPC creation |
| `dhcp_options_id` | The ID of the DHCP options set assigned to the VPC |
| `owner_id` | The ID of the AWS account that owns the VPC |
| `tags_all` | A map of tags assigned to the resource, including provider default_tags |
| `assign_generated_ipv6_cidr_block` | Whether an Amazon-provided IPv6 CIDR block is requested |
| `ipv6_association_id` | The association ID for the IPv6 CIDR block |
| `ipv6_cidr_block_network_border_group` | The Network Border Group Zone name |
