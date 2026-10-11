/******************************************
  AWS SNS Root Module
 *****************************************/

module "sns" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/sns?ref=v0.9.5"
  for_each = var.sns

  name                        = each.value.name_prefix != null ? null : coalesce(each.value.name, each.key)
  name_prefix                 = each.value.name_prefix
  display_name                = each.value.display_name
  kms_master_key_id           = each.value.kms_master_key_id
  fifo_topic                  = each.value.fifo_topic
  content_based_deduplication = each.value.content_based_deduplication
  delivery_policy             = each.value.delivery_policy
  policy                      = each.value.policy
  subscriptions               = each.value.subscriptions
  tags                        = each.value.tags
}
