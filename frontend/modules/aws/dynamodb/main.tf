/******************************************
  AWS DynamoDB Root Module
 *****************************************/

module "dynamodb" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/dynamodb?ref=v0.9.19"
  for_each = var.dynamodb

  name                         = coalesce(each.value.name, each.key)
  billing_mode                 = each.value.billing_mode
  hash_key                     = each.value.hash_key
  range_key                    = each.value.range_key
  read_capacity                = each.value.read_capacity
  write_capacity               = each.value.write_capacity
  table_class                  = each.value.table_class
  deletion_protection_enabled  = each.value.deletion_protection_enabled
  stream_enabled               = each.value.stream_enabled
  stream_view_type             = each.value.stream_view_type
  contributor_insights_enabled = each.value.contributor_insights_enabled

  attribute              = each.value.attribute
  global_secondary_index = each.value.global_secondary_index
  local_secondary_index  = each.value.local_secondary_index
  ttl                    = each.value.ttl
  point_in_time_recovery = each.value.point_in_time_recovery
  server_side_encryption = each.value.server_side_encryption
  replica                = each.value.replica
  autoscaling            = each.value.autoscaling

  tags = each.value.tags
}
