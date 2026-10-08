# AWS SNS Topic Terraform Module

This module provisions an Amazon Simple Notification Service (SNS) Topic with support for standard and FIFO topics, KMS encryption, topic policies, and subscriptions.

## Usage

### Standard SNS Topic

```hcl
module "sns_topic" {
  source = "../../modules/aws/sns"

  name         = "alerts-topic"
  display_name = "Alerts"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### FIFO Topic with Subscriptions & Policy

```hcl
module "fifo_sns_topic" {
  source = "../../modules/aws/sns"

  name                        = "orders.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
  kms_master_key_id           = "alias/aws/sns"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = "*"
      }
    ]
  })

  subscriptions = [
    {
      name     = "ops_email"
      protocol = "email"
      endpoint = "devops@example.com"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the SNS topic. Set at most one of name/name_prefix. Must end in `.fifo` when `fifo_topic` is true, and must not otherwise | `string` | `"sns-default"` | no |
| `name_prefix` | Prefix for the SNS topic name | `string` | `null` | no |
| `display_name` | The display name for SNS topic | `string` | `null` | no |
| `kms_master_key_id` | KMS CMK ID or alias for encryption | `string` | `null` | no |
| `fifo_topic` | Whether to create a FIFO topic | `bool` | `false` | no |
| `content_based_deduplication` | Enables deduplication for FIFO topics. Can only be true when `fifo_topic` is true | `bool` | `false` | no |
| `delivery_policy` | SNS delivery policy as JSON string | `string` | `null` | no |
| `policy` | IAM policy JSON string to apply to topic | `string` | `null` | no |
| `subscriptions` | List of subscriptions to create. Each needs a unique `name` (Terraform-only, not sent to AWS) | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ARN of the SNS topic |
| `arn` | The ARN of the SNS topic |
| `name` | The name of the SNS topic |
| `owner` | The AWS Account ID of the SNS topic owner |
| `policy_id` | The ID of the topic policy, if created |
| `tags_all` | A map of tags assigned to the resource |
