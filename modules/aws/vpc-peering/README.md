# AWS VPC Peering Terraform Module

This module provisions an AWS VPC Peering Connection between two Amazon VPCs.

## Usage

```hcl
module "vpc_peering" {
  source      = "path/to/modules/aws/vpc-peering"
  name        = "prod-to-dev-peering"
  vpc_id      = "vpc-0123456789abcdef0"
  peer_vpc_id = "vpc-0fedcba9876543210"
  auto_accept = true

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc\_id | Requester VPC ID | `string` | n/a | yes |
| peer\_vpc\_id | Accepter VPC ID | `string` | n/a | yes |
| name | Connection name identifier | `string` | `"vpc-peering"` | no |
| peer\_owner\_id | Peer AWS account ID | `string` | `null` | no |
| peer\_region | Peer AWS region | `string` | `null` | no |
| auto\_accept | Auto accept connection (same account/region only) | `bool` | `false` | no |
| allow\_remote\_vpc\_dns\_resolution | Enable remote VPC DNS resolution | `bool` | `false` | no |
| tags | Map of resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | VPC Peering Connection ID |
| accept\_status | Status of the peering connection request |
| vpc\_id | Requester VPC ID |
| peer\_vpc\_id | Accepter VPC ID |
