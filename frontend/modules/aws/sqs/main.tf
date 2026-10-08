/******************************************
  AWS SQS Root Module
 *****************************************/

module "sqs" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/sqs?ref=v0.8.13"
  for_each = var.sqs

  name                              = coalesce(each.value.name, each.key)
  name_prefix                       = each.value.name_prefix
  visibility_timeout_seconds        = each.value.visibility_timeout_seconds
  message_retention_seconds         = each.value.message_retention_seconds
  max_message_size                  = each.value.max_message_size
  delay_seconds                     = each.value.delay_seconds
  receive_wait_time_seconds         = each.value.receive_wait_time_seconds
  policy                            = each.value.policy
  redrive_policy                    = each.value.redrive_policy
  redrive_allow_policy              = each.value.redrive_allow_policy
  fifo_queue                        = each.value.fifo_queue
  content_based_deduplication       = each.value.content_based_deduplication
  deduplication_scope               = each.value.deduplication_scope
  fifo_throughput_limit             = each.value.fifo_throughput_limit
  kms_master_key_id                 = each.value.kms_master_key_id
  kms_data_key_reuse_period_seconds = each.value.kms_data_key_reuse_period_seconds
  sqs_managed_sse_enabled           = each.value.sqs_managed_sse_enabled
  tags                              = each.value.tags
}
