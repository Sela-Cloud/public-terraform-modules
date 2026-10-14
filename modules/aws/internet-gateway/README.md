# AWS Internet Gateway Terraform Module

This generic Terraform module provisions an Amazon VPC Internet Gateway, attached directly to a VPC
on creation, and optionally an Egress-Only Internet Gateway (IPv6 outbound-only) for the same VPC.

## Usage

```hcl
module "internet_gateway" {
  source = "../../modules/aws/internet-gateway"

  name   = "prod-igw"
  vpc_id = "vpc-0123456789abcdef0"

  tags = {
    Environment = "production"
  }
}
```

### With an Egress-Only Internet Gateway (IPv6 outbound-only)

```hcl
module "internet_gateway" {
  source = "../../modules/aws/internet-gateway"

  name                       = "prod-igw"
  vpc_id                     = "vpc-0123456789abcdef0"
  create_egress_only_gateway = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name applied as the 'Name' tag. | `string` | `"internet-gateway-default"` | no |
| vpc_id | VPC ID to attach the Internet Gateway to. Leave null to create a detached gateway. | `string` | `null` | no |
| create_egress_only_gateway | Also create an Egress-Only Internet Gateway attached to the same VPC. Requires `vpc_id`. | `bool` | `false` | no |
| tags | A map of tags to assign to all resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Internet Gateway. |
| arn | The ARN of the Internet Gateway. |
| owner_id | The ID of the AWS account that owns the Internet Gateway. |
| egress_only_gateway_id | The ID of the Egress-Only Internet Gateway, if created. |

## Notes

- The Internet Gateway attaches directly via `vpc_id` on creation. AWS also offers a separate
  `aws_internet_gateway_attachment` resource for attaching an already-created gateway, but direct
  attachment is simpler and is what this module uses, matching the convention of every other
  gateway-style module in this catalog (e.g. `nat-gateway`, `vpc-peering`).
- An Egress-Only Internet Gateway is a separate AWS resource (IPv6 outbound-only, no inbound);
  it's created alongside the regular Internet Gateway only when `create_egress_only_gateway = true`.
