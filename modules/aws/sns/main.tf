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
}

resource "aws_sns_topic_policy" "this" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.policy
}

resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  topic_arn             = aws_sns_topic.this.arn
  protocol              = each.value.protocol
  endpoint              = each.value.endpoint
  raw_message_delivery = lookup(each.value, "raw_message_delivery", false)
  filter_policy         = lookup(each.value, "filter_policy", null)
}
