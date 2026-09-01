/******************************************
  Details of the regional Managed Instance Group
 *****************************************/

module "mig" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/mig?ref=v0.6.14"
  for_each = var.mig

  project_id        = var.project_id
  hostname          = each.value.hostname
  mig_name          = each.value.mig_name
  region            = each.value.region
  instance_template = each.value.instance_template

  # The remote module ignores target_size while an autoscaler owns the group.
  target_size               = each.value.target_size
  target_pools              = each.value.target_pools
  distribution_policy_zones = each.value.distribution_policy_zones
  named_ports               = each.value.named_ports
  wait_for_instances        = each.value.wait_for_instances
  mig_timeouts              = each.value.mig_timeouts

  stateful_disks = each.value.stateful_disks
  stateful_ips   = each.value.stateful_ips

  update_policy    = each.value.update_policy
  lifecycle_policy = each.value.lifecycle_policy

  health_check_name = each.value.health_check_name
  health_check      = each.value.health_check

  autoscaling_enabled = each.value.autoscaling_enabled
  autoscaler_name     = each.value.autoscaler_name
  min_replicas        = each.value.min_replicas
  max_replicas        = each.value.max_replicas
  cooldown_period     = each.value.cooldown_period
  autoscaling_mode    = each.value.autoscaling_mode
  autoscaling_cpu     = each.value.autoscaling_cpu
  autoscaling_metric  = each.value.autoscaling_metric

  # The remote module types this as list(map(number)); the form collects it as a
  # list of single-target objects, which converts cleanly.
  autoscaling_lb = each.value.autoscaling_lb

  scaling_schedules            = each.value.scaling_schedules
  autoscaling_scale_in_control = each.value.autoscaling_scale_in_control
}
