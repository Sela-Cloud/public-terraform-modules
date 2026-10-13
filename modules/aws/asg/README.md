# AWS Auto Scaling Group Terraform Module

This module provisions an Amazon EC2 Auto Scaling Group from an existing Launch Template, with
optional instance refresh (rolling updates), target-tracking scaling policies, and scheduled
scaling actions.

## Usage

```hcl
module "asg" {
  source = "../../modules/aws/asg"

  hostname          = "web"
  subnet_ids        = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
  instance_template = "lt-0123456789abcdef0"

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  target_pools = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/web/abc123"]

  health_check = {
    type              = "ELB"
    initial_delay_sec = 300
  }

  autoscaling_policies = [
    {
      metric_name = "ASGAverageCPUUtilization"
      target      = 60
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `hostname` | Base name for instances and resources | `string` | n/a | yes |
| `asg_name` | Explicit group name. Falls back to `<hostname>-asg` when empty | `string` | `""` | no |
| `subnet_ids` | Subnets where the instances will deploy | `list(string)` | n/a | yes |
| `instance_template` | The ID of the EC2 Launch Template | `string` | n/a | yes |
| `instance_template_version` | Launch template version, `$Latest`, or `$Default` | `string` | `"$Latest"` | no |
| `desired_capacity` | Fixed size used only when `autoscaling_enabled` is false | `number` | `2` | no |
| `min_size` | Minimum group size | `number` | `1` | no |
| `max_size` | Maximum group size | `number` | `5` | no |
| `cooldown_period` | Seconds used as the target-tracking policies' estimated instance warmup | `number` | `300` | no |
| `autoscaling_enabled` | When true, size is driven by scaling policies; `desired_capacity` is ignored | `bool` | `true` | no |
| `health_check` | Map with `type` (`EC2` or `ELB`) and `initial_delay_sec` | `map(any)` | `{type = "EC2", initial_delay_sec = 300}` | no |
| `target_pools` | ARNs of target groups to attach to the ASG | `list(string)` | `[]` | no |
| `update_policy` | List of instance refresh policies (`type`, `min_healthy_percentage`, `max_healthy_percentage`, `instance_warmup`) | `list(any)` | `[]` | no |
| `autoscaling_policies` | List of target-tracking scaling policy configs | `list(any)` | `[]` | no |
| `scaling_schedules` | List of scheduled scaling actions | `list(any)` | `[]` | no |
| `tags` | Tags applied to the group with `propagate_at_launch = true` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `asg_id` | The Auto Scaling Group ID |
| `asg_arn` | The Auto Scaling Group ARN |
| `asg_name` | The Auto Scaling Group name |
| `autoscaling_policies` | Map of created target-tracking scaling policies and their ARNs |
| `scaling_schedules` | Map of created scaling schedules and their ARNs |
