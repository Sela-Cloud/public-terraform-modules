# AWS Security Group Terraform Module

This module provisions an AWS Security Group and its associated ingress and egress rules.

## Usage

```hcl
module "security_group" {
  source      = "path/to/modules/aws/security-group"
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = "vpc-0123456789abcdef0"

  ingress_rules = [
    {
      description = "HTTPS access"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc\_id | VPC ID where security group is created | `string` | n/a | yes |
| name | Security group name | `string` | `"security-group-default"` | no |
| description | Security group description | `string` | `"Managed by Terraform"` | no |
| revoke\_rules\_on\_delete | Revoke rules before deleting | `bool` | `false` | no |
| ingress\_rules | List of ingress rules | `list(object)` | `[]` | no |
| egress\_rules | List of egress rules | `list(object)` | `[]` | no |
| tags | Map of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Security Group ID |
| arn | Security Group ARN |
| name | Security Group Name |
| vpc\_id | VPC ID |
| owner\_id | Owner Account ID |
