################################################################################
# AWS SNS Topic Resource
################################################################################

resource "aws_sns_topic" "this" {
  name                        = var.name_prefix == null ? var.name : null
  name_prefix                 = var.name_prefix
  display_name                = var.display_name
  kms_master_key_id           = var.kms_master_key_id
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  delivery_policy             = var.delivery_policy

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
      condition     = var.name_prefix != null || var.name == null || var.fifo_topic == endswith(var.name, ".fifo")
      error_message = "name must end with '.fifo' when fifo_topic is true, and must not end with '.fifo' when fifo_topic is false."
    }
    precondition {
      condition     = !var.content_based_deduplication || var.fifo_topic
      error_message = "content_based_deduplication can only be true when fifo_topic is true."
    }
    precondition {
      condition     = length(distinct([for s in var.subscriptions : s.name])) == length(var.subscriptions)
      error_message = "Each subscription's name must be unique."
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.policy
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for s in var.subscriptions : s.name => s }

  topic_arn            = aws_sns_topic.this.arn
  protocol             = each.value.protocol
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy
}
