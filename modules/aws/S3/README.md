# S3 bucket and object module

Creates an Amazon S3 bucket and one object with commonly required security and configuration options.

The module supports S3 server-side encryption, versioning, public access blocking, object ownership controls, optional lifecycle configuration, and an optional bucket policy.

S3 folders are virtual: specify a slash-delimited `object_key` to place the object in a folder-like prefix.

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

  versioning_enabled = true
  force_destroy      = false

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
Inputs
Name	Type	Default	Description
bucket_name	string	n/a	Globally unique S3 bucket name.
object_key	string	n/a	Object key; include a prefix such as uploads/hello.txt for a folder-like path.
object_content	string	""	Text written to the object.
object_content_type	string	"text/plain"	Object MIME type.
tags	map(string)	{}	Bucket tags.
object_tags	map(string)	{}	Object tags.
versioning_enabled	bool	true	Enable bucket versioning.
force_destroy	bool	false	Allow Terraform to delete all objects when destroying the bucket.
block_public_acls	bool	true	Block public ACLs for the bucket.
block_public_policy	bool	true	Block public bucket policies.
ignore_public_acls	bool	true	Ignore public ACLs for the bucket.
restrict_public_buckets	bool	true	Restrict public bucket policies.
object_ownership	string	"BucketOwnerEnforced"	S3 object ownership setting. Supported values are BucketOwnerEnforced, BucketOwnerPreferred, and ObjectWriter.
lifecycle_enabled	bool	false	Enable the default S3 lifecycle configuration.
lifecycle_expiration_days	number	365	Number of days after which current objects are deleted when lifecycle is enabled.
noncurrent_version_expiration_days	number	30	Number of days after which noncurrent object versions are deleted.
bucket_policy	string	null	Optional JSON-formatted S3 bucket policy.
Outputs
Name	Description
bucket_id	S3 bucket name.
bucket_arn	S3 bucket ARN.
bucket_regional_domain_name	Bucket regional domain name.
object_key	Created object key.
object_version_id	Created object version ID.
object_ownership	Object ownership configuration of the S3 bucket.
public_access_block_enabled	Indicates that public access blocking is configured.
Security

The module enables the following secure defaults:

SSE-S3 (AES256) server-side encryption.
Public access blocking.
BucketOwnerEnforced object ownership.
Versioning enabled by default.

Public access blocking is configured using:

block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

These settings help prevent accidental public access to the S3 bucket.

Lifecycle Configuration

Lifecycle management is disabled by default.

To enable lifecycle management:

lifecycle_enabled = true

lifecycle_expiration_days          = 365
noncurrent_version_expiration_days = 30

When enabled:

Current objects are deleted after the configured number of days.
Noncurrent object versions are deleted after the configured number of days.

Review lifecycle settings carefully before enabling them because they can result in permanent object deletion.

Bucket Policy

A custom bucket policy can be provided using the bucket_policy variable.

Example:

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

Use bucket policies carefully and grant only the permissions required for the use case.

Notes
S3 bucket names must be globally unique.
S3 folders are virtual and are represented through object key prefixes.
The bucket and object use SSE-S3 (AES256) server-side encryption.
Versioning is enabled by default.
Public access is blocked by default.
Object ownership defaults to BucketOwnerEnforced.
Lifecycle management is disabled by default.
force_destroy is disabled by default.
The module does not configure an AWS provider; configure the region and credentials in the calling configuration.