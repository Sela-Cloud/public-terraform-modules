# AWS Launch Template Terraform Module

This module provisions an Amazon EC2 Launch Template with support for AMIs, instance types, key pairs, user data, IAM instance profiles, security groups, EBS block device mappings, network interfaces, and tags.

## Usage

### Basic Usage

```hcl
module "launch_template" {
  source = "../../modules/aws/lt"

  name          = "my-launch-template"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  key_name      = "my-key"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Full Usage

```hcl
module "launch_template" {
  source = "../../modules/aws/lt"

  name                   = "app-launch-template"
  description            = "Launch template for web application instances"
  image_id               = "ami-0c55b159cbfafe1f0"
  instance_type          = "t3.medium"
  key_name               = "production-key"
  ebs_optimized          = true
  vpc_security_group_ids = ["sg-0123456789abcdef0"]

  iam_instance_profile_name = "app-ec2-role"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              EOF

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Role = "WebServer"
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "Portal"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the launch template. Set at most one of name/name_prefix | `string` | `null` | no |
| `name_prefix` | Creates a unique name beginning with prefix | `string` | `null` | no |
| `description` | Description of the launch template | `string` | `null` | no |
| `image_id` | The AMI ID to use to launch the instance | `string` | `null` | no |
| `instance_type` | The instance type to use | `string` | `"t3.micro"` | no |
| `key_name` | The key name to use for the instance | `string` | `null` | no |
| `user_data` | The user data script (base64 or raw text) | `string` | `null` | no |
| `ebs_optimized` | Whether the instance is EBS-optimized | `bool` | `null` | no |
| `vpc_security_group_ids` | List of security group IDs | `list(string)` | `null` | no |
| `update_default_version` | Whether to update Default Version on each change | `bool` | `true` | no |
| `iam_instance_profile_name` | Name of IAM instance profile | `string` | `null` | no |
| `iam_instance_profile_arn` | ARN of IAM instance profile | `string` | `null` | no |
| `enable_monitoring` | Whether to enable detailed CloudWatch monitoring | `bool` | `null` | no |
| `block_device_mappings` | EBS volume configurations | `list(object)` | `[]` | no |
| `network_interfaces` | Network interface configurations | `list(object)` | `[]` | no |
| `tag_specifications` | Resource tag specifications | `list(object)` | `[]` | no |
| `tags` | A map of tags to assign to the launch template | `map(string)` | `{}` | no |
| `disable_api_termination` | Enables EC2 instance termination protection | `bool` | `null` | no |
| `disable_api_stop` | Enables EC2 instance stop protection | `bool` | `null` | no |
| `instance_initiated_shutdown_behavior` | Shutdown behavior (`stop` or `terminate`) | `string` | `null` | no |
| `placement` | Instance placement (availability zone, tenancy, host, placement group) | `object` | `null` | no |
| `cpu_options` | CPU core count and threads per core | `object` | `null` | no |
| `credit_specification` | CPU credit option for burstable (T-family) instances | `object` | `null` | no |
| `instance_market_options` | Purchasing option (e.g. Spot) for the instance | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the launch template |
| `arn` | The ARN of the launch template |
| `name` | The name of the launch template |
| `default_version` | The default version of the launch template |
| `latest_version` | The latest version of the launch template |
| `tags_all` | A map of tags assigned to the resource |
