# AWS Subnet Terraform Module

This module provisions an Amazon Virtual Private Cloud (VPC) Subnet with configurable IPv4/IPv6 CIDR blocks, availability zone placement, public IP assignment, and DNS resolution options.

## Features

- **IPv4 CIDR Support**: Configurable IPv4 CIDR block with safe default (`10.0.1.0/24`).
- **Availability Zone Placement**: Supports explicit AZ selection via `availability_zone` or `availability_zone_id`.
- **Public IPv4 Addressing**: Configurable auto-assignment of public IP addresses on instance launch (`map_public_ip_on_launch`).
- **IPv6 Capabilities**: Support for assigning IPv6 addresses on creation, specifying IPv6 CIDR blocks, and creating IPv6-only subnets (`ipv6_native`).
- **DNS & Hostname Settings**: Options for DNS64 synthetic IPv6 responses, custom hostname assignment types (`ip-name`, `resource-name`), and DNS A/AAAA record auto-creation.
- **Local Network Interfaces**: Support for custom local network interface device indexing (`enable_lni_at_device_index`).
- **Standard Tagging**: Built-in tagging merged with the `Name` identifier tag.

## Usage

### Basic Usage

```hcl
module "subnet" {
  source = "../../modules/aws/subnet"

  name       = "my-public-subnet"
  vpc_id     = "vpc-0123456789abcdef0"
  cidr_block = "10.0.1.0/24"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Full Configuration

```hcl
module "subnet" {
  source = "../../modules/aws/subnet"

  name                                           = "app-subnet-1a"
  vpc_id                                         = "vpc-0123456789abcdef0"
  cidr_block                                     = "10.0.10.0/24"
  availability_zone                              = "us-east-1a"
  map_public_ip_on_launch                        = true
  assign_ipv6_address_on_creation                = false
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = true
  enable_resource_name_dns_aaaa_record_on_launch = false
  private_dns_hostname_type_on_launch           = "ip-name"

  tags = {
    Environment = "production"
    Tier        = "frontend"
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
| name | Name to be used on all resources as identifier, applied as the 'Name' tag. | `string` | `"subnet-default"` | no |
| vpc_id | The VPC ID where the subnet will be created. | `string` | `""` | no |
| cidr_block | The IPv4 CIDR block for the subnet. | `string` | `"10.0.1.0/24"` | no |
| availability_zone | AZ for the subnet. | `string` | `null` | no |
| availability_zone_id | AZ ID of the subnet. | `string` | `null` | no |
| map_public_ip_on_launch | Specify true to indicate that instances launched into the subnet should be assigned a public IP address. | `bool` | `false` | no |
| assign_ipv6_address_on_creation | Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address. | `bool` | `false` | no |
| ipv6_cidr_block | The IPv6 network range for the subnet (/64 prefix length). | `string` | `null` | no |
| ipv6_native | Indicates whether to create an IPv6-only subnet. | `bool` | `false` | no |
| enable_dns64 | Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet return synthetic IPv6 addresses for IPv4 destinations. | `bool` | `false` | no |
| enable_resource_name_dns_a_record_on_launch | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. | `bool` | `false` | no |
| enable_resource_name_dns_aaaa_record_on_launch | Indicates whether to respond to DNS queries for instance hostnames with DNS AAAA records. | `bool` | `false` | no |
| private_dns_hostname_type_on_launch | The type of hostnames to assign to instances in the subnet at launch ('ip-name', 'resource-name'). | `string` | `null` | no |
| enable_lni_at_device_index | Indicates the device position for local network interfaces in this subnet. | `number` | `null` | no |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the subnet. |
| arn | The ARN of the subnet. |
| vpc_id | The VPC ID. |
| cidr_block | The IPv4 CIDR block of the subnet. |
| availability_zone | The availability zone of the subnet. |
| availability_zone_id | The availability zone ID of the subnet. |
| ipv6_cidr_block | The IPv6 network range for the subnet. |
| ipv6_cidr_block_association_id | The association ID for the IPv6 CIDR block. |
| owner_id | The ID of the AWS account that owns the subnet. |
| tags_all | A map of tags assigned to the resource, including those inherited from provider default_tags. |
