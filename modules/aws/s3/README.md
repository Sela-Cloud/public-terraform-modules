# S3 bucket and object module

Creates an Amazon S3 bucket and one object with commonly required security and configuration options.

The module supports S3 server-side encryption, versioning, public access blocking, object ownership controls, Object Lock, CORS, static website hosting, optional lifecycle configuration, and an optional bucket policy.

S3 folders are virtual: specify a slash-delimited `object_key` to place the object in a folder-like prefix.

The module requires Terraform 1.5+ and AWS provider 5.0+; these requirements are declared in `versions.tf`. The module does not configure an AWS provider itself; configure the region and credentials in the calling configuration.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "./modules/aws/s3"

  bucket_name         = "my-unique-example-bucket"
  object_key          = "uploads/hello.txt"
  object_content      = "Hello from Terraform!"
  object_content_type = "text/plain"

  versioning_enabled = true
  force_destroy       = false

  object_ownership = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_enabled = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }

  object_tags = {
    Type = "Example"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| bucket_name | `string` | n/a | Globally unique S3 bucket name. |
| object_key | `string` | n/a | Object key; include a prefix such as `uploads/hello.txt` for a folder-like path. |
| object_content | `string` | `""` | Text written to the object. |
| object_content_type | `string` | `"text/plain"` | Object MIME type. |
| tags | `map(string)` | `{}` | Bucket tags. |
| object_tags | `map(string)` | `{}` | Object tags. |
| versioning_enabled | `bool` | `true` | Enable bucket versioning. |
| force_destroy | `bool` | `false` | Allow Terraform to delete all objects when destroying the bucket. |
| block_public_acls | `bool` | `true` | Block public ACLs for the bucket. |
| block_public_policy | `bool` | `true` | Block public bucket policies. |
| ignore_public_acls | `bool` | `true` | Ignore public ACLs for the bucket. |
| restrict_public_buckets | `bool` | `true` | Restrict public bucket policies. |
| object_ownership | `string` | `"BucketOwnerEnforced"` | S3 object ownership setting. Supported values are `BucketOwnerEnforced`, `BucketOwnerPreferred`, and `ObjectWriter`. |
| kms_master_key_id | `string` | `null` | The AWS KMS key used for server-side encryption. If null, SSE-S3 (AES256) is used. Must be a full key/alias **ARN** -- `aws_s3_object` rejects the bare `alias/...` shorthand that `aws_s3_bucket_server_side_encryption_configuration` otherwise accepts, so this module always requires the ARN form to keep both resources consistent. |
| bucket_key_enabled | `bool` | `true` | Whether to use an S3 Bucket Key for SSE-KMS. |
| logging_target_bucket | `string` | `null` | Target bucket for storing server access logs. Access logging is only created when this is set. |
| logging_target_prefix | `string` | `"log/"` | Prefix for server access log objects. |
| acceleration_status | `string` | `null` | Transfer Acceleration status (`Enabled` or `Suspended`). |
| object_lock_enabled | `bool` | `false` | Whether to enable Object Lock. Set at bucket creation time and cannot be changed afterward. Requires `versioning_enabled = true`. |
| object_lock_mode | `string` | `"GOVERNANCE"` | Default Object Lock retention mode (`GOVERNANCE` or `COMPLIANCE`). |
| object_lock_days | `number` | `null` | Default Object Lock retention, in days. |
| object_lock_years | `number` | `null` | Default Object Lock retention, in years. |
| cors_rules | `list(any)` | `[]` | CORS rules to apply to the bucket. |
| acl | `string` | `null` | Canned ACL to apply to the bucket (e.g. `private`, `public-read`). Cannot be used when `object_ownership = "BucketOwnerEnforced"`. |
| grants | `list(any)` | `[]` | List of ACL grant rules. Same `object_ownership` restriction as `acl`. |
| owner_id | `string` | `null` | Canonical user ID of the bucket owner, required when `grants` is set. |
| website_enabled | `bool` | `false` | Enable static website hosting. |
| website_index_document | `string` | `"index.html"` | Index document for the website. |
| website_error_document | `string` | `null` | Error document for the website. |
| website_redirect_all_requests_to | `map(string)` | `null` | Redirect-all-requests configuration for the website. |
| lifecycle_enabled | `bool` | `false` | Enable the default S3 lifecycle configuration. |
| lifecycle_expiration_days | `number` | `365` | Number of days after which current objects are deleted when lifecycle is enabled. |
| noncurrent_version_expiration_days | `number` | `30` | Number of days after which noncurrent object versions are deleted. |
| bucket_policy | `string` | `null` | Optional JSON-formatted S3 bucket policy. |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | S3 bucket name. |
| bucket_arn | S3 bucket ARN. |
| bucket_domain_name | Bucket domain name (`bucketname.s3.amazonaws.com`). |
| bucket_regional_domain_name | Bucket region-specific domain name. |
| object_id | Created object key. |
| object_version_id | Created object's version ID, if versioning is enabled. |
| website_endpoint | Website endpoint URL, if website hosting is enabled. |
| website_domain | Website endpoint domain, if website hosting is enabled. |

## Security

The module enables the following secure defaults:

- SSE-S3 (AES256) server-side encryption.
- Public access blocking.
- `BucketOwnerEnforced` object ownership.
- Versioning enabled by default.

Public access blocking is configured using:

```hcl
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true
```

These settings help prevent accidental public access to the S3 bucket.

### ACL / Object Ownership

`acl` and `grants` can only be used when `object_ownership` is `BucketOwnerPreferred` or `ObjectWriter` -- AWS disables ACLs entirely under `BucketOwnerEnforced` (the module's default), and the module enforces this with a plan-time precondition.

### Object Lock

`object_lock_enabled` requires `versioning_enabled = true`; the module enforces this with a plan-time precondition. Object Lock is set on the bucket at creation time and cannot be enabled on an existing bucket.

## Lifecycle Configuration

Lifecycle management is disabled by default.

To enable lifecycle management:

```hcl
lifecycle_enabled = true

lifecycle_expiration_days          = 365
noncurrent_version_expiration_days = 30
```

When enabled:

- Current objects are deleted after the configured number of days.
- Noncurrent object versions are deleted after the configured number of days.

Review lifecycle settings carefully before enabling them because they can result in permanent object deletion.

## Bucket Policy

A custom bucket policy can be provided using the `bucket_policy` variable.

Example:

```hcl
bucket_policy = jsonencode({
  Version = "2012-10-17"

  Statement = [
    {
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "arn:aws:s3:::my-unique-example-bucket/*"
    }
  ]
})
```

Use bucket policies carefully and grant only the permissions required for the use case.

## Notes

- S3 bucket names must be globally unique.
- S3 folders are virtual and are represented through object key prefixes.
- The bucket and object use SSE-S3 (AES256) server-side encryption by default, or SSE-KMS when `kms_master_key_id` is set.
- Versioning is enabled by default.
- Public access is blocked by default.
- Object ownership defaults to `BucketOwnerEnforced`.
- Lifecycle management is disabled by default.
- `force_destroy` is disabled by default.
- The module always creates exactly one `aws_s3_object` alongside the bucket -- it is not an optional object store, it always provisions one seed object.
- The module does not configure an AWS provider; configure the region and credentials in the calling configuration.
