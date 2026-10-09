# AWS SQS Queue Terraform Module

This module provisions an Amazon Simple Queue Service (SQS) Queue with support for Standard and FIFO queues, Server-Side Encryption (SSE-SQS & KMS), deduplication, redrive policies, and IAM access policies.

## Usage

### Standard Queue

```hcl
module "sqs_queue" {
  source = "../../modules/aws/sqs"

  name                       = "order-processing-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800 # 7 days
  receive_wait_time_seconds  = 20     # Long polling

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### FIFO Queue with Deduplication

```hcl
module "fifo_queue" {
  source = "../../modules/aws/sqs"

  name                        = "transactions.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  tags = {
    Environment = "production"
  }
}
```

### Queue with Dead Letter Queue (DLQ) Redrive Policy

```hcl
module "dlq" {
  source = "../../modules/aws/sqs"

  name                      = "orders-dlq"
  message_retention_seconds = 1209600 # 14 days
}

module "orders_queue" {
  source = "../../modules/aws/sqs"

  name = "orders-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.dlq.arn
    maxReceiveCount     = 3
  })
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the SQS queue. Set at most one of name/name_prefix. Must end in `.fifo` when `fifo_queue` is true, and must not otherwise | `string` | `"sqs-default"` | no |
| `name_prefix` | Prefix for the SQS queue name. Conflicts with `name` | `string` | `null` | no |
| `visibility_timeout_seconds` | Visibility timeout in seconds (0 to 43200) | `number` | `30` | no |
| `message_retention_seconds` | Retention in seconds (60 to 1209600) | `number` | `345600` | no |
| `max_message_size` | Max message size in bytes | `number` | `262144` | no |
| `delay_seconds` | Delivery delay in seconds (0 to 900) | `number` | `0` | no |
| `receive_wait_time_seconds` | ReceiveMessage wait time in seconds (0 to 20) | `number` | `0` | no |
| `fifo_queue` | Boolean designating a FIFO queue | `bool` | `false` | no |
| `content_based_deduplication` | Enables content-based deduplication. Can only be true when `fifo_queue` is true | `bool` | `false` | no |
| `deduplication_scope` | Deduplication scope, `messageGroup` or `queue`. Only applies when `fifo_queue` is true | `string` | `null` | no |
| `fifo_throughput_limit` | Throughput quota scope, `perQueue` or `perMessageGroupId`. Only applies when `fifo_queue` is true | `string` | `null` | no |
| `kms_master_key_id` | KMS CMK ID or alias for encryption. Conflicts with `sqs_managed_sse_enabled` | `string` | `null` | no |
| `kms_data_key_reuse_period_seconds` | Seconds SQS can reuse a data key (60 to 86400) | `number` | `300` | no |
| `sqs_managed_sse_enabled` | Enable SSE-SQS encryption. Automatically disabled whenever `kms_master_key_id` is set, since AWS allows only one encryption mode | `bool` | `true` | no |
| `policy` | IAM policy JSON string | `string` | `null` | no |
| `redrive_policy` | Redrive policy JSON string | `string` | `null` | no |
| `redrive_allow_policy` | Redrive allow policy JSON string | `string` | `null` | no |
| `tags` | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The URL of the created Amazon SQS queue |
| `arn` | The ARN of the SQS queue |
| `url` | The URL of the SQS queue |
| `name` | The name of the SQS queue |
| `tags_all` | A map of tags assigned to the resource |
