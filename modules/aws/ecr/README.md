# AWS ECR Repository Terraform Module

This module provisions an Amazon Elastic Container Registry (ECR) repository with configurable image tag mutability, automatic image scanning on push, encryption (AES-256 or AWS KMS), force deletion options, and resource tags.

## Usage

```hcl
module "ecr" {
  source = "path/to/modules/aws/ecr"

  name                 = "my-app-repository"
  image_tag_mutability = "MUTABLE"
  force_delete         = false
  scan_on_push         = true
  encryption_type      = "AES256"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### With AWS KMS Encryption

```hcl
module "ecr" {
  source = "path/to/modules/aws/ecr"

  name                 = "my-secure-repository"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false
  scan_on_push         = true
  encryption_type      = "KMS"
  kms_key              = "arn:aws:kms:us-east-1:123456789012:key/your-kms-key-id"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the repository | `string` | `"ecr-default"` | no |
| image\_tag\_mutability | Tag mutability setting (`MUTABLE` or `IMMUTABLE`) | `string` | `"MUTABLE"` | no |
| force\_delete | Delete repository even if it contains images | `bool` | `false` | no |
| scan\_on\_push | Whether images are scanned after being pushed | `bool` | `true` | no |
| encryption\_type | Encryption type (`AES256` or `KMS`) | `string` | `"AES256"` | no |
| kms\_key | KMS key ARN when encryption_type is KMS | `string` | `null` | no |
| tags | Map of tags to assign to the repository | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The registry name / ID of the repository |
| arn | The ARN of the repository |
| name | The name of the repository |
| registry\_id | The registry ID where the repository was created |
| repository\_url | The URL of the repository |
| tags\_all | Map of tags assigned to the resource |
