# S3 bucket and object module

Creates an Amazon S3 bucket and one object. S3 folders are virtual: specify a slash-delimited `object_key` to place the object in a folder-like prefix.

The module requires Terraform 1.3+ and AWS provider 5.0+; these requirements are declared in `versions.tf`.

## Usage

```hcl
provider "aws" {
  region = "ap-south-1"
}

module "s3" {
  source = "./modules/aws/S3"

  bucket_name         = "my-unique-example-bucket"
  object_key          = "uploads/hello.txt"
  object_content      = "Hello from Terraform!"
  object_content_type = "text/plain"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `bucket_name` | `string` | n/a | Globally unique S3 bucket name. |
| `object_key` | `string` | n/a | Object key; include a prefix such as `uploads/hello.txt` for a folder-like path. |
| `object_content` | `string` | `""` | Text written to the object. |
| `object_content_type` | `string` | `"text/plain"` | Object MIME type. |
| `tags` | `map(string)` | `{}` | Bucket tags. |
| `object_tags` | `map(string)` | `{}` | Object tags. |
| `versioning_enabled` | `bool` | `true` | Enable bucket versioning. |
| `force_destroy` | `bool` | `false` | Allow Terraform to delete all objects when destroying the bucket. |

## Outputs

| Name | Description |
| --- | --- |
| `bucket_id` | S3 bucket name. |
| `bucket_arn` | S3 bucket ARN. |
| `bucket_regional_domain_name` | Bucket regional domain name. |
| `object_key` | Created object key. |
| `object_version_id` | Created object version ID. |

## Notes

The bucket and object use SSE-S3 (`AES256`) server-side encryption. This module does not configure an AWS provider; configure the region and credentials in the calling configuration.
