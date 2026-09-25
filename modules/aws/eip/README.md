# AWS Elastic IP (EIP) Terraform Module

This Terraform module provisions and manages an AWS Elastic IP (EIP) resource within Amazon VPC, supporting instance association, network interface (ENI) association, BYOIP pools, and IPAM pools.

## Features

- **VPC Allocation**: Allocates static public IPv4 addresses for use in Amazon VPC.
- **Compute Association**: Direct association with Amazon EC2 instances or Elastic Network Interfaces (ENIs).
- **Private IP Mapping**: Map Elastic IP to specific primary or secondary private IP addresses.
- **Bring Your Own IP (BYOIP)**: Support for custom IPv4 address pools and specific BYOIP addresses.
- **Amazon VPC IPAM**: Allocation from Amazon VPC IP Address Manager (IPAM) pools.
- **Network Border Groups**: Restrict IP address advertisement to specific AWS regions or Local Zones.
- **Standard Tagging**: Automatic merging of custom tags with resource `Name` tag identifier.

## Usage

### Standalone Elastic IP (VPC)

```hcl
module "eip" {
  source = "../../modules/aws/eip"

  name = "my-standalone-eip"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Elastic IP Associated with an EC2 Instance

```hcl
module "eip" {
  source = "../../modules/aws/eip"

  name     = "my-web-eip"
  instance = "i-0123456789abcdef0"

  tags = {
    Environment = "production"
    Service     = "web"
  }
}
```

### Elastic IP Associated with a Network Interface and Private IP

```hcl
module "eip" {
  source = "../../modules/aws/eip"

  name                      = "my-eni-eip"
  network_interface         = "eni-0123456789abcdef0"
  associate_with_private_ip = "10.0.1.50"
}
```

### Allocating from a BYOIP or IPAM Pool

```hcl
module "eip" {
  source = "../../modules/aws/eip"

  name         = "my-ipam-eip"
  ipam_pool_id = "ipam-pool-07ccc86aa41bef7ce"
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
| name | Name to be used on all resources as identifier, applied as the 'Name' tag. | `string` | `"eip-default"` | no |
| domain | Indicates if this EIP is for use in VPC ('vpc'). In AWS provider v5+, 'vpc' is the standard domain. | `string` | `"vpc"` | no |
| instance | EC2 instance ID to associate with the Elastic IP. Conflicts with `network_interface`. | `string` | `null` | no |
| network_interface | Network interface ID to associate with the Elastic IP. Conflicts with `instance`. | `string` | `null` | no |
| associate_with_private_ip | User-specified primary or secondary private IP address to associate with the Elastic IP address. | `string` | `null` | no |
| public_ipv4_pool | EC2 IPv4 address pool identifier or 'amazon'. This option is only available for VPC EIPs. | `string` | `null` | no |
| network_border_group | Location from which the IP address is advertised. Use this parameter to limit the address to this location. | `string` | `null` | no |
| customer_owned_ipv4_pool | ID of a customer-owned address pool for AWS Outposts. | `string` | `null` | no |
| ipam_pool_id | The ID of an IPAM pool which has an Amazon-provided or BYOIP public IPv4 CIDR provisioned to it. | `string` | `null` | no |
| address | IP address from an EC2 BYOIP pool. This option is only available for VPC EIPs. | `string` | `null` | no |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Contains the EIP allocation ID. |
| allocation_id | ID that AWS assigns to represent the allocation of the Elastic IP address for use with instances in a VPC. |
| association_id | ID representing the association of the address with an instance in a VPC. |
| carrier_ip | Carrier IP address. |
| customer_owned_ip | Customer owned IP. |
| domain | Indicates if this EIP is for use in VPC ('vpc'). |
| instance | The ID representing the instance associated with the Elastic IP. |
| network_interface | The ID representing the network interface associated with the Elastic IP. |
| private_dns | The Private DNS associated with the Elastic IP address (if in VPC). |
| private_ip | Contains the private IP address (if in VPC). |
| ptr_record | The DNS pointer (PTR) record for the IP address. |
| public_dns | Public DNS associated with the Elastic IP address. |
| public_ip | Contains the public IP address. |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider default_tags. |
