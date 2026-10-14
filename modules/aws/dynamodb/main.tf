################################################################################
# DynamoDB Table
################################################################################

resource "aws_dynamodb_table" "this" {
  name           = var.name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  table_class    = var.table_class

  deletion_protection_enabled = var.deletion_protection_enabled
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_enabled ? var.stream_view_type : null

  dynamic "attribute" {
    for_each = var.attribute
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = { for g in var.global_secondary_index : g.key => g }
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
      read_capacity      = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = { for l in var.local_secondary_index : l.key => l }
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.non_key_attributes
    }
  }

  dynamic "ttl" {
    for_each = [var.ttl]
    content {
      enabled        = ttl.value.enabled
      attribute_name = ttl.value.enabled ? ttl.value.attribute_name : null
    }
  }

  dynamic "point_in_time_recovery" {
    for_each = [var.point_in_time_recovery]
    content {
      enabled                 = point_in_time_recovery.value.enabled
      recovery_period_in_days = point_in_time_recovery.value.enabled ? point_in_time_recovery.value.recovery_period_in_days : null
    }
  }

  dynamic "server_side_encryption" {
    for_each = [var.server_side_encryption]
    content {
      enabled     = server_side_encryption.value.enabled
      kms_key_arn = server_side_encryption.value.enabled ? server_side_encryption.value.kms_key_arn : null
    }
  }

  dynamic "replica" {
    for_each = { for r in var.replica : r.key => r }
    content {
      region_name                 = replica.value.region_name
      kms_key_arn                 = replica.value.kms_key_arn
      propagate_tags              = replica.value.propagate_tags
      consistency_mode            = replica.value.consistency_mode
      point_in_time_recovery      = replica.value.point_in_time_recovery
      deletion_protection_enabled = replica.value.deletion_protection_enabled
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition     = contains([for a in var.attribute : a.name], var.hash_key)
      error_message = "hash_key must appear in the attribute list."
    }
    precondition {
      condition     = var.range_key == null || contains([for a in var.attribute : a.name], var.range_key)
      error_message = "range_key, if set, must appear in the attribute list."
    }
    precondition {
      condition     = var.billing_mode != "PROVISIONED" || (var.read_capacity != null && var.write_capacity != null)
      error_message = "read_capacity and write_capacity are required when billing_mode is PROVISIONED."
    }
    precondition {
      condition     = var.billing_mode == "PROVISIONED" || (var.read_capacity == null && var.write_capacity == null)
      error_message = "read_capacity and write_capacity must be left null when billing_mode is PAY_PER_REQUEST."
    }
    precondition {
      condition = alltrue([
        for gsi in var.global_secondary_index :
        var.billing_mode != "PROVISIONED" || (gsi.read_capacity != null && gsi.write_capacity != null)
      ])
      error_message = "Each global_secondary_index entry needs read_capacity and write_capacity when billing_mode is PROVISIONED."
    }
    precondition {
      condition     = length(var.local_secondary_index) == 0 || var.range_key != null
      error_message = "local_secondary_index requires the table to have its own range_key -- LSIs need a composite primary key."
    }
    precondition {
      condition     = !var.ttl.enabled || var.ttl.attribute_name != null
      error_message = "ttl.attribute_name is required when ttl.enabled is true."
    }
    precondition {
      condition     = length(distinct([for g in var.global_secondary_index : g.key])) == length(var.global_secondary_index)
      error_message = "Each global_secondary_index entry needs a unique key."
    }
    precondition {
      condition     = length(distinct([for l in var.local_secondary_index : l.key])) == length(var.local_secondary_index)
      error_message = "Each local_secondary_index entry needs a unique key."
    }
    precondition {
      condition     = length(distinct([for r in var.replica : r.key])) == length(var.replica)
      error_message = "Each replica entry needs a unique key."
    }
    precondition {
      condition     = length(distinct([for a in var.autoscaling : a.key])) == length(var.autoscaling)
      error_message = "Each autoscaling entry needs a unique key."
    }
    precondition {
      condition     = var.billing_mode == "PROVISIONED" || length(var.autoscaling) == 0
      error_message = "autoscaling can only be configured when billing_mode is PROVISIONED."
    }
    precondition {
      condition = alltrue([
        for a in var.autoscaling :
        contains(["table_read", "table_write"], a.dimension) || a.index_name != null
      ])
      error_message = "autoscaling entries targeting a GSI (gsi_read/gsi_write) must set index_name."
    }
    precondition {
      condition = alltrue([
        for a in var.autoscaling :
        contains(["table_read", "table_write"], a.dimension) || contains([for g in var.global_secondary_index : g.name], coalesce(a.index_name, ""))
      ])
      error_message = "autoscaling entries' index_name must match an existing global_secondary_index name."
    }
  }
}

################################################################################
# Contributor Insights
################################################################################

resource "aws_dynamodb_contributor_insights" "this" {
  count      = var.contributor_insights_enabled ? 1 : 0
  table_name = aws_dynamodb_table.this.name
}

################################################################################
# Auto Scaling
################################################################################

locals {
  autoscaling_targets = {
    for a in var.autoscaling : a.key => {
      resource_id = contains(["table_read", "table_write"], a.dimension) ? "table/${var.name}" : "table/${var.name}/index/${a.index_name}"
      scalable_dimension = (
        a.dimension == "table_read" ? "dynamodb:table:ReadCapacityUnits" :
        a.dimension == "table_write" ? "dynamodb:table:WriteCapacityUnits" :
        a.dimension == "gsi_read" ? "dynamodb:index:ReadCapacityUnits" :
        "dynamodb:index:WriteCapacityUnits"
      )
      predefined_metric_type = (
        contains(["table_read", "gsi_read"], a.dimension) ? "DynamoDBReadCapacityUtilization" : "DynamoDBWriteCapacityUtilization"
      )
      min_capacity = a.min_capacity
      max_capacity = a.max_capacity
      target_value = a.target_value
    }
  }
}

resource "aws_appautoscaling_target" "this" {
  for_each = local.autoscaling_targets

  service_namespace  = "dynamodb"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  min_capacity       = each.value.min_capacity
  max_capacity       = each.value.max_capacity

  depends_on = [
    aws_dynamodb_table.this
  ]
}

resource "aws_appautoscaling_policy" "this" {
  for_each = local.autoscaling_targets

  name               = "${var.name}-${each.key}"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this[each.key].service_namespace
  resource_id        = aws_appautoscaling_target.this[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.this[each.key].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value = each.value.target_value

    predefined_metric_specification {
      predefined_metric_type = each.value.predefined_metric_type
    }
  }
}
