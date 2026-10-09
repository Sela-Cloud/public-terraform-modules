# AWS ACM Certificate Terraform Module

This module provisions an SSL/TLS certificate using AWS Certificate Manager (ACM) with support for DNS and EMAIL validation, Subject Alternative Names (SANs), and optional Route 53 DNS validation records.

## Usage

### DNS-Validated Certificate with Route 53

```hcl
module "acm_certificate" {
  source = "../../modules/aws/acm"

  name        = "api-cert"
  domain_name = "api.example.com"

  subject_alternative_names = [
    "auth.example.com"
  ]

  create_route53_records = true
  zone_id                = "Z1234567890ABCDEF"
  validate_certificate   = true

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Wildcard Certificate

```hcl
module "wildcard_cert" {
  source = "../../modules/aws/acm"

  name        = "wildcard-example-com"
  domain_name = "example.com"

  subject_alternative_names = [
    "*.example.com"
  ]

  validation_method = "DNS"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name identifier applied as the 'Name' tag | `string` | `"acm-certificate-default"` | no |
| `domain_name` | Domain name for the certificate | `string` | `"example.com"` | no |
| `validation_method` | Validation method (`DNS`, `EMAIL`) | `string` | `"DNS"` | no |
| `subject_alternative_names` | Set of domains that should be SANs | `list(string)` | `[]` | no |
| `key_algorithm` | Key algorithm (`RSA_2048`, `ECDSA_P256`, etc.) | `string` | `"RSA_2048"` | no |
| `certificate_authority_arn` | ARN of an ACM Private CA | `string` | `null` | no |
| `create_route53_records` | Whether to create Route 53 DNS records | `bool` | `false` | no |
| `zone_id` | Route 53 Hosted Zone ID | `string` | `null` | no |
| `validate_certificate` | Whether to wait for certificate validation | `bool` | `false` | no |
| `tags` | A map of tags to assign to the certificate | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ARN of the certificate |
| `arn` | The ARN of the certificate |
| `domain_name` | The domain name of the certificate |
| `status` | Status of the certificate |
| `domain_validation_options` | Set of domain validation objects |
| `tags_all` | A map of tags assigned to the resource |
