################################################################################
# AWS SQS Queue Resource
################################################################################

resource "aws_sqs_queue" "this" {
  name                              = var.name_prefix == null ? var.name : null
  name_prefix                       = var.name_prefix
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  policy                            = var.policy
  redrive_policy                    = var.redrive_policy
  redrive_allow_policy              = var.redrive_allow_policy
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  deduplication_scope               = var.deduplication_scope
  fifo_throughput_limit             = var.fifo_throughput_limit
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  sqs_managed_sse_enabled           = var.kms_master_key_id == null ? var.sqs_managed_sse_enabled : null

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )

  lifecycle {
    precondition {
      condition     = var.name == null || var.name_prefix == null
      error_message = "Set only one of name or name_prefix, not both."
    }
    precondition {
      condition     = var.name_prefix != null || var.name == null || var.fifo_queue == endswith(var.name, ".fifo")
      error_message = "FIFO queues (fifo_queue = true) must have a name ending in '.fifo', and non-FIFO queues must not."
    }
    precondition {
      condition     = !var.content_based_deduplication || var.fifo_queue
      error_message = "content_based_deduplication can only be true when fifo_queue is true."
    }
    precondition {
      condition     = var.deduplication_scope == null || var.fifo_queue
      error_message = "deduplication_scope only applies to FIFO queues (fifo_queue = true)."
    }
    precondition {
      condition     = var.fifo_throughput_limit == null || var.fifo_queue
      error_message = "fifo_throughput_limit only applies to FIFO queues (fifo_queue = true)."
    }
  }
}
