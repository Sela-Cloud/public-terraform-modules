# AWS Secrets Manager Secret Terraform Module

This module provisions an Amazon Secrets Manager secret, with optional KMS encryption, multi-region
replication, and automatic rotation via a Lambda function.

## Usage

```hcl
module "secret" {
  source = "../../modules/aws/secret"

  secret_id   = "prod/app/db-password"
  description = "Database password for the production app tier"

  tags = {
    Environment = "production"
  }
}
```

### With replication and rotation

```hcl
module "secret" {
  source = "../../modules/aws/secret"

  secret_id = "prod/app/api-key"

  custom_replication = true
  replica_regions = [
    { region = "us-west-2" },
    { region = "eu-west-1", kms_key_id = "alias/eu-secrets" }
  ]

  set_rotation                 = true
  rotation_lambda_arn          = "arn:aws:lambda:us-east-1:123456789012:function:rotate-secret"
  rotation_schedule_expression = "rate(30 days)"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `secret_id` | Friendly name of the secret | `string` | n/a | yes |
| `description` | A description of the secret | `string` | `null` | no |
| `kms_key_id` | ARN or ID of the KMS key to protect the primary secret. Defaults to the `aws/secretsmanager` key when null | `string` | `null` | no |
| `recovery_window_in_days` | Days AWS waits before permanently deleting the secret. 0 to 7-30, or 0 to delete immediately | `number` | `30` | no |
| `tags` | Key-value tags assigned to the secret | `map(string)` | `{}` | no |
| `custom_replication` | Replicate the secret into other regions | `bool` | `false` | no |
| `replica_regions` | Regions to replicate into, each with an optional region-specific KMS key | `list(object({region, kms_key_id}))` | `[]` | no |
| `set_rotation` | Provision automatic rotation parameters | `bool` | `false` | no |
| `rotation_lambda_arn` | ARN of the Lambda function that performs rotation | `string` | `null` | no |
| `rotation_period_days` | Days between rotations. Set this or `rotation_schedule_expression`, not both | `number` | `null` | no |
| `rotation_duration` | Length of the rotation window (e.g. `"3h"`) | `string` | `null` | no |
| `rotation_schedule_expression` | Cron or rate expression for when the secret rotates | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ARN of the secret |
| `arn` | The ARN of the secret |
| `name` | The friendly name of the secret |
| `replica_attributes` | Attributes of the secret replicas, including status |
| `rotation_enabled` | Whether automatic rotation is configured |
