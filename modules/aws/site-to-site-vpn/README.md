# AWS Site-to-Site VPN Terraform Module

This generic Terraform module provisions an AWS Site-to-Site VPN connection: a Customer Gateway
(created by this module, or an existing one referenced by ID) plus a VPN Connection to either a
Virtual Private Gateway or a Transit Gateway, with full control over both tunnels and optional static
routes. Mirrors the AWS Console's own combined "Site-to-Site VPN Connection" creation flow, which
likewise lets you create a new Customer Gateway inline or pick an existing one.

## Usage

### Dynamic (BGP) routing to a Virtual Private Gateway

```hcl
module "site_to_site_vpn" {
  source = "../../modules/aws/site-to-site-vpn"

  name = "prod-s2s-vpn"

  customer_gateway_ip_address = "203.0.113.1"
  customer_gateway_bgp_asn    = "65000"

  vpn_gateway_id = "vgw-0123456789abcdef0"

  tunnel1 = {
    preshared_key = "SuperSecretKey123"
  }
  tunnel2 = {
    preshared_key = "AnotherSecretKey456"
  }

  tags = {
    Environment = "production"
  }
}
```

### Static routing to a Transit Gateway, with acceleration

```hcl
module "site_to_site_vpn" {
  source = "../../modules/aws/site-to-site-vpn"

  name = "prod-tgw-vpn"

  customer_gateway_ip_address = "203.0.113.5"
  customer_gateway_bgp_asn    = "65000"

  transit_gateway_id  = "tgw-0123456789abcdef0"
  enable_acceleration = true
  static_routes_only  = true

  routes = [
    { key = "office-net", destination_cidr_block = "192.168.0.0/16" }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

See `variables.tf` for the full list -- this module exposes every argument the
`aws_customer_gateway`, `aws_vpn_connection`, and `aws_vpn_connection_route` resources support, in
the shape the real resources take (`tunnel1`/`tunnel2` are nested objects in this module for
readability, flattened back to AWS's own flat `tunnel1_*`/`tunnel2_*` attribute names internally).

## Outputs

| Name | Description |
|------|-------------|
| customer_gateway_id | The ID of the Customer Gateway (created or referenced). |
| customer_gateway_arn | The ARN of the Customer Gateway, if created by this module. |
| vpn_connection_id | The ID of the VPN Connection. |
| vpn_connection_arn | The ARN of the VPN Connection. |
| customer_gateway_configuration | The customer gateway's configuration XML (sensitive). |
| tunnel1_address / tunnel2_address | The public IP of each VPN tunnel. |
| tunnel1_preshared_key / tunnel2_preshared_key | Each tunnel's pre-shared key (sensitive). |
| routes | Map of static route keys to their resource IDs. |

## Notes, verified against the real AWS provider and its documentation

- **Exactly one of `vpn_gateway_id` or `transit_gateway_id`** is required -- enforced by a
  precondition.
- **`enable_acceleration` only works together with `transit_gateway_id`** -- confirmed directly from
  the provider's own error (`"all of enable_acceleration,transit_gateway_id must be specified"`), not
  just the docs. This module only passes `enable_acceleration` through to AWS when
  `transit_gateway_id` is set; it's silently ignored with a Virtual Private Gateway.
- **`tunnel_bandwidth` is incompatible with `vpn_gateway_id` or acceleration enabled** -- enforced by
  a precondition.
- **`outside_ip_address_type = "PrivateIpv4"` requires `transport_transit_gateway_attachment_id`** --
  enforced by a precondition.
- **`customer_gateway_bgp_asn` and `customer_gateway_bgp_asn_extended` are mutually exclusive** --
  enforced by a precondition (both also force replacement of the customer gateway if changed, per
  AWS).
- **`routes` only applies when `static_routes_only = true`** -- with BGP dynamic routing, AWS
  determines routes automatically; enforced by a precondition.
- Every tunnel option is optional. AWS fills in its own sensible defaults for anything left null:
  Phase 1 lifetime 28800s, Phase 2 lifetime 3600s, DPD timeout 30s, rekey margin 540s, replay window
  1024 packets, startup action `add`, tunnel bandwidth `standard` (the other valid value is `large`),
  and inside CIDRs auto-assigned from `169.254.0.0/16`.
- `transit_gateway_id` has no catalog lookup to pick from -- this catalog doesn't create Transit
  Gateways yet, so it's a plain text field rather than a dropdown that could never be populated.
- `customer_gateway_certificate_arn` (device certificate authentication) is also plain text: the
  catalog's existing `acm.certificates` lookup returns public ACM certificates, not the private-CA
  device certificates this field actually needs, and a dropdown offering the wrong kind of value
  would be worse than none.
