# 1. The Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                = var.asg_name == "" ? "${var.hostname}-asg" : var.asg_name
  vpc_zone_identifier = var.subnet_ids

  # Fallback to desired_capacity if autoscaling is off
  desired_capacity = var.autoscaling_enabled ? null : var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  launch_template {
    id      = var.instance_template
    version = var.instance_template_version
  }

  # Health Check Configuration (Equivalent to Auto Healing Policies)
  health_check_type         = var.health_check["type"] # EC2 or ELB
  health_check_grace_period = var.health_check["initial_delay_sec"]
  target_group_arns         = var.target_pools

  # Instance Maintenance and Refresh (Equivalent to Update Policy)
  dynamic "instance_refresh" {
    for_each = var.update_policy
    content {
      strategy = instance_refresh.value.type
      preferences {
        min_healthy_percentage = lookup(instance_refresh.value, "min_healthy_percentage", 50)
        max_healthy_percentage = lookup(instance_refresh.value, "max_healthy_percentage", 200)
        instance_warmup        = lookup(instance_refresh.value, "instance_warmup", null)
      }
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# 2. Dynamic Target Tracking Policies (Equivalent to GCP Region Autoscaler Blocks)
resource "aws_autoscaling_policy" "target_tracking" {
  # Evaluates how many configurations are passed into the list
  for_each = { for idx, policy in var.autoscaling_policies : idx => policy if var.autoscaling_enabled }

  name                      = "${var.hostname}-policy-${each.key}"
  autoscaling_group_name    = aws_autoscaling_group.asg.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = var.cooldown_period

  target_tracking_configuration {
    target_value = each.value.target

    # Renders predefined metrics like CPU, Network, or ALB Request Count
    dynamic "predefined_metric_specification" {
      for_each = each.value.is_custom_metric ? [] : [1]
      content {
        predefined_metric_type = each.value.metric_name
        resource_label         = lookup(each.value, "resource_label", null)
      }
    }

    # Renders custom CloudWatch metrics if specified
    dynamic "customized_metric_specification" {
      for_each = each.value.is_custom_metric ? [1] : []
      content {
        metric_dimension {
          name  = lookup(each.value.custom_metric, "dimension_name", null)
          value = lookup(each.value.custom_metric, "dimension_value", null)
        }
        metric_name = each.value.metric_name
        namespace   = lookup(each.value.custom_metric, "namespace", null)
        statistic   = lookup(each.value.custom_metric, "statistic", "Average")
      }
    }
  }
}

# 3. Scheduled Actions (Equivalent to GCP Scaling Schedules)
resource "aws_autoscaling_schedule" "schedule" {
  for_each = { for idx, sched in var.scaling_schedules : idx => sched if !lookup(sched, "disabled", false) }

  scheduled_action_name  = lookup(each.value, "name", "${var.hostname}-schedule-${each.key}")
  autoscaling_group_name = aws_autoscaling_group.asg.name

  min_size         = lookup(each.value, "min_required_replicas", -1)
  max_size         = lookup(each.value, "max_size", -1)
  desired_capacity = lookup(each.value, "desired_capacity", -1)

  recurrence = each.value.schedule # Cron statement format
  time_zone  = lookup(each.value, "time_zone", "UTC")
}
