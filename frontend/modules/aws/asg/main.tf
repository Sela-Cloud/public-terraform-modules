/******************************************
  Details of the regional Auto Scaling Groups
 *****************************************/

module "asg" {
  # Points to your local or remote AWS autoscaling child module
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/asg?ref=v0.9.5"
  for_each = var.asg

  hostname                  = each.value.hostname
  asg_name                  = each.value.asg_name
  subnet_ids                = each.value.subnet_ids
  instance_template         = each.value.instance_template
  instance_template_version = each.value.instance_template_version

  # Module handles desired_capacity evaluation depending on autoscaling_enabled
  desired_capacity = each.value.desired_capacity
  min_size         = each.value.min_size
  max_size         = each.value.max_size
  target_pools     = each.value.target_pools
  cooldown_period  = each.value.cooldown_period

  update_policy = each.value.update_policy
  health_check  = each.value.health_check

  autoscaling_enabled  = each.value.autoscaling_enabled
  autoscaling_policies = each.value.autoscaling_policies
  scaling_schedules    = each.value.scaling_schedules
  tags                 = each.value.tags
}
