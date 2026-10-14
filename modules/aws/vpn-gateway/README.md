# AWS VPN Gateway (Virtual Private Gateway) Terraform Module

This generic Terraform module provisions an Amazon Virtual Private Gateway, attached directly to a
VPC on creation, and optional route propagation into one or more route tables for dynamic
(BGP-learned) routing from a Site-to-Site VPN connection.

## Usage

```hcl
module "vpn_gateway" {
  source = "../../modules/aws/vpn-gateway"

  name   = "prod-vgw"
  vpc_id = "vpc-0123456789abcdef0"

  route_table_ids = ["rtb-0123456789abcdef0"]

  tags = {
    Environment = "production"
  }
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
| name | Name applied as the 'Name' tag. | `string` | `"vpn-gateway-default"` | no |
| vpc_id | VPC ID to attach the gateway to. Leave null to create a detached gateway. | `string` | `null` | no |
| availability_zone | The Availability Zone for the gateway. | `string` | `null` | no |
| amazon_side_asn | ASN for the Amazon side of the gateway. If null, AWS assigns the default ASN. | `string` | `null` | no |
| route_table_ids | Route tables this gateway's BGP-learned routes should propagate into. | `list(string)` | `[]` | no |
| tags | A map of tags to assign to all resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Virtual Private Gateway. |
| arn | The ARN of the Virtual Private Gateway. |
| amazon_side_asn | The ASN for the Amazon side of the gateway. |
| route_propagation_ids | Map of route table IDs to their route propagation resource IDs. |

## Notes

- Attaches directly via `vpc_id` on creation, same convention as `internet-gateway` in this catalog
  (AWS's separate `aws_vpn_gateway_attachment` resource is an alternate path this module doesn't use).
- Route propagation only matters for dynamic (BGP) routing. A `site-to-site-vpn` connection using
  `static_routes_only = true` does not need `route_table_ids` set here.
