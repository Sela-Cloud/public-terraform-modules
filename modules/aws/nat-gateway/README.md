# AWS NAT Gateway Terraform Module

This module provisions an Amazon Virtual Private Cloud (VPC) NAT Gateway with support for both zonal (single-AZ) and regional (multi-AZ) availability modes, public or private connectivity, Elastic IP allocations, and secondary IP configurations.

## Features

- **Dual Availability Modes**: Supports standard `zonal` (single-AZ) deployment into a subnet as well as `regional` (multi-AZ) managed deployment across a VPC.
- **Flexible Connectivity**: Supports both `public` (internet-facing egress) and `private` (internal egress routing without internet gateway) connectivity types.
- **Elastic IP Management**: Primary EIP allocation support for zonal gateways and multi-AZ `availability_zone_address` mapping for regional gateways.
- **Secondary Private & Public IP Scaling**: Support for `secondary_allocation_ids`, `secondary_private_ip_addresses`, and `secondary_private_ip_address_count` for zonal NAT gateways.
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Public Zonal NAT Gateway (Single-AZ)

```hcl
module "nat_gateway" {
  source = "../../modules/aws/nat-gateway"

  name              = "my-public-nat-gw"
  availability_mode = "zonal"
  connectivity_type = "public"
  subnet_id         = "subnet-0123456789abcdef0"
  allocation_id     = "eipalloc-0123456789abcdef0"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Private Zonal NAT Gateway

```hcl
module "private_nat_gateway" {
  source = "../../modules/aws/nat-gateway"

  name              = "my-private-nat-gw"
  availability_mode = "zonal"
  connectivity_type = "private"
  subnet_id         = "subnet-0123456789abcdef0"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Regional NAT Gateway (Auto Mode)

```hcl
module "regional_nat_gateway" {
  source = "../../modules/aws/nat-gateway"

  name              = "my-regional-nat-gw"
  availability_mode = "regional"
  connectivity_type = "public"
  vpc_id            = "vpc-0123456789abcdef0"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Regional NAT Gateway (Manual Mode with AZ Addresses)

```hcl
module "regional_nat_gateway_manual" {
  source = "../../modules/aws/nat-gateway"

  name              = "my-regional-nat-gw-manual"
  availability_mode = "regional"
  connectivity_type = "public"
  vpc_id            = "vpc-0123456789abcdef0"

  availability_zone_address = [
    {
      availability_zone = "us-east-1a"
      allocation_ids    = ["eipalloc-0123456789abcdef0"]
    },
    {
      availability_zone = "us-east-1b"
      allocation_ids    = ["eipalloc-0abcdef1234567890"]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
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
| name | Name to be used on all resources as identifier, applied as the 'Name' tag. | `string` | `"nat-gateway-default"` | no |
| availability_mode | Specifies whether to create a zonal (single-AZ) or regional (multi-AZ) NAT gateway ('zonal', 'regional'). | `string` | `"zonal"` | no |
| connectivity_type | Connectivity type for the NAT Gateway ('private', 'public'). | `string` | `"public"` | no |
| subnet_id | The Subnet ID of the subnet in which to place the NAT Gateway. Required when availability_mode is 'zonal'. | `string` | `null` | no |
| allocation_id | The Allocation ID of the Elastic IP address for the NAT Gateway. Required when connectivity_type is 'public' and availability_mode is 'zonal'. | `string` | `null` | no |
| vpc_id | VPC ID where this NAT Gateway will be created. Required when availability_mode is 'regional'. | `string` | `null` | no |
| private_ip | The private IPv4 address to assign to the NAT Gateway (zonal NAT gateways only). | `string` | `null` | no |
| secondary_allocation_ids | A list of secondary allocation EIP IDs for this NAT Gateway (zonal NAT gateways only). | `list(string)` | `[]` | no |
| secondary_private_ip_addresses | A list of secondary private IPv4 addresses to assign to the NAT Gateway (zonal NAT gateways only). | `list(string)` | `[]` | no |
| secondary_private_ip_address_count | The number of secondary private IPv4 addresses to assign to the NAT Gateway (zonal and private NAT gateways only). | `number` | `null` | no |
| availability_zone_address | Configuration block for Elastic IP addresses and availability zones for regional NAT gateways. | `list(object({...}))` | `[]` | no |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the NAT Gateway. |
| allocation_id | The Allocation ID of the Elastic IP address for the NAT Gateway (zonal). |
| association_id | The association ID of the Elastic IP address that's associated with the NAT Gateway (zonal). |
| network_interface_id | The ID of the network interface associated with the NAT Gateway (zonal). |
| public_ip | The Elastic IP address associated with the NAT Gateway (zonal). |
| route_table_id | The ID of the automatically created route table (regional). |
| auto_provision_zones | Indicates whether AWS automatically manages AZ coverage (regional). |
| auto_scaling_ips | Indicates whether AWS automatically allocates additional Elastic IP addresses (regional). |
| regional_nat_gateway_address | Information about the IP addresses and network interfaces associated with the regional NAT gateway. |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider default_tags. |
