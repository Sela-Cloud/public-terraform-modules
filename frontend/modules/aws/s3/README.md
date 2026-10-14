# AWS S3 Frontend Module

This frontend module wraps the core AWS S3 module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one S3 bucket, with one seed object, and the full range of security, encryption, lifecycle, and hosting options the child module supports.

## Usage

```hcl
module "s3" {
  source = "./frontend/modules/aws/s3"

  region = "us-east-1"

  s3 = {
    "my-unique-example-bucket" = {
      object_key     = "uploads/hello.txt"
      object_content = "Hello from Terraform!"

      versioning_enabled = true
      object_ownership   = "BucketOwnerEnforced"

      tags = {
        Environment = "production"
      }
    }
  }
}
```
