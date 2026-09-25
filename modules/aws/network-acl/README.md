# AWS Network ACL Terraform Module

This module provisions an AWS Network Access Control List (NACL) resource (`aws_network_acl`) to provide a stateless layer of traffic filtering for subnets within an Amazon VPC.

## Features

- **Subnet Association**: Associate multiple VPC subnets with the Network ACL directly via `subnet_ids`.
- **Dynamic Ingress Rules**: Define customizable inbound stateless filtering rules using rule numbers, protocols, port ranges, and CIDR blocks.
- **Dynamic Egress Rules**: Define customizable outbound stateless filtering rules.
- **Protocol Flexibility**: Full support for TCP, UDP, ICMP, and all protocols (`-1`).
- **IPv4 and IPv6**: Support for both IPv4 and IPv6 CIDR blocks.
- **Standard Tagging**: Built-in tagging merged with the resource `Name` tag identifier.

## Usage

### Basic Usage with HTTP/HTTPS Ingress and All Outbound Egress

```hcl
module "network_acl" {
  source = "../../modules/aws/network-acl"

  name       = "web-subnet-nacl"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0"]

  ingress = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "tcp"
      from_port  = 80
      to_port    = 80
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 110
      action     = "allow"
      protocol   = "tcp"
      from_port  = 443
      to_port    = 443
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 120
      action     = "allow"
      protocol   = "tcp"
      from_port  = 1024
      to_port    = 65535
      cidr_block = "0.0.0.0/0"
    }
  ]

  egress = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      cidr_block = "0.0.0.0/0"
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
| name | Name to be used on all resources as identifier, applied as the 'Name' tag. | `string` | `"network-acl-default"` | no |
| vpc_id | The ID of the associated VPC. | `string` | `""` | yes |
| subnet_ids | A list of Subnet IDs to apply the ACL to. | `list(string)` | `[]` | no |
| ingress | Specifies ingress rules for the network ACL. | `list(object)` | `[]` | no |
| egress | Specifies egress rules for the network ACL. | `list(object)` | `[]` | no |
| tags | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

### Ingress / Egress Rule Object Schema

| Key | Description | Type | Default | Required |
|-----|-------------|------|---------|:--------:|
| rule_no | The rule number used for evaluation order (1 to 32766). Lower numbers evaluated first. | `number` | - | yes |
| action | The action to take: 'allow' or 'deny'. | `string` | `"allow"` | no |
| protocol | The protocol to match: 'tcp', 'udp', 'icmp', or '-1' (all). | `string` | `"-1"` | no |
| from_port | Start of port range (0-65535). Use 0 for all protocols. | `number` | `0` | no |
| to_port | End of port range (0-65535). Use 0 for all protocols. | `number` | `0` | no |
| cidr_block | The IPv4 CIDR block to match (e.g. 0.0.0.0/0). | `string` | `null` | no |
| ipv6_cidr_block | The IPv6 CIDR block to match. | `string` | `null` | no |
| icmp_type | The ICMP type code (required if protocol is ICMP). | `number` | `null` | no |
| icmp_code | The ICMP code (required if protocol is ICMP). | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Network ACL. |
| arn | The ARN of the Network ACL. |
| owner_id | The ID of the AWS account that owns the Network ACL. |
| vpc_id | The VPC ID associated with the Network ACL. |
| subnet_ids | The list of Subnet IDs associated with the Network ACL. |
| ingress | The set of ingress rules configured on the Network ACL. |
| egress | The set of egress rules configured on the Network ACL. |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider default_tags. |
