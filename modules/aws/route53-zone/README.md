# AWS Route 53 Hosted Zone Terraform Module

This module provisions an Amazon Route 53 hosted zone, public or private. A zone becomes private
by associating it with one or more VPCs.

## Usage

### Public zone

```hcl
module "zone" {
  source = "../../modules/aws/route53-zone"

  name    = "example.com"
  comment = "Primary public zone"

  tags = {
    Environment = "production"
  }
}
```

### Private zone

```hcl
module "zone" {
  source = "../../modules/aws/route53-zone"

  name = "internal.example.com"

  vpc_associations = [
    { vpc_id = "vpc-0123456789abcdef0" },
    { vpc_id = "vpc-0fedcba9876543210", vpc_region = "us-west-2" }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Domain name for the hosted zone, e.g. `example.com` | `string` | n/a | yes |
| `comment` | Free-text description of the hosted zone | `string` | `null` | no |
| `force_destroy` | Whether Terraform may delete all records in the zone when destroying it | `bool` | `false` | no |
| `vpc_associations` | VPCs to associate for a private hosted zone. Leave empty for a public zone | `list(object({vpc_id, vpc_region}))` | `[]` | no |
| `delegation_set_id` | Reusable delegation set to assign fixed name servers from. Public zones only | `string` | `null` | no |
| `tags` | Tags assigned to the hosted zone | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The hosted zone ID |
| `arn` | The ARN of the hosted zone |
| `name_servers` | The zone's delegation set name servers, to configure at the domain registrar |
| `primary_name_server` | The Route 53 name server that created the SOA record |
