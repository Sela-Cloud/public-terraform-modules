# AWS EC2 Instance Terraform Module

This module provisions an AWS EC2 instance with comprehensive configuration options, secure defaults (IMDSv2 enforced, encrypted root volume), secondary EBS volume attachments, and optional Elastic IP (EIP).

## Features

- **Automated Fallback AMI**: Defaults to the latest Amazon Linux 2023 AMI if no AMI is provided.
- **Root Block Device Configuration**: Customizable gp3/gp2 volume with encryption enabled by default.
- **Secondary EBS Volumes**: Dynamically create and attach secondary EBS volumes with independent lifecycle.
- **Security & IMDSv2**: Enforces IMDSv2 (`http_tokens = "required"`, hop limit `2`) by default for enhanced security.
- **Elastic IP (EIP)**: Optional automated Elastic IP allocation and association.
- **Full Customizability**: Supports user data, custom shutdown behavior, detailed CloudWatch monitoring, EBS optimization, CPU credit options, termination protection, and tags.

## Usage

```hcl
module "ec2_instance" {
  source = "../../modules/aws/ec2-instance"

  name          = "web-server"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"

  vpc_security_group_ids = [
    "sg-0123456789abcdef0"
  ]

  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name to be used on all resources as identifier, applied as the 'Name' tag | `string` | `"ec2-instance"` | no |
| `ami` | The AMI to use for the instance. If null, the latest Amazon Linux 2023 AMI is used | `string` | `null` | no |
| `instance_type` | The instance type of the EC2 instance | `string` | `"t3.micro"` | no |
| `key_name` | The key name of the Key Pair to use for the instance | `string` | `null` | no |
| `subnet_id` | The VPC Subnet ID to launch in | `string` | `null` | no |
| `vpc_security_group_ids` | A list of security group IDs to associate with | `list(string)` | `[]` | no |
| `associate_public_ip_address` | Whether to associate a public IP address with an instance in a VPC | `bool` | `false` | no |
| `private_ip` | Private IP address to associate with the instance in a VPC | `string` | `null` | no |
| `secondary_private_ips` | A list of secondary private IPv4 addresses to assign to the primary network interface | `list(string)` | `[]` | no |
| `source_dest_check` | Controls if traffic is routed to the instance when destination doesn't match | `bool` | `true` | no |
| `availability_zone` | AZ where the instance should be created | `string` | `null` | no |
| `placement_group` | The placement group to start the instance in | `string` | `null` | no |
| `tenancy` | The tenancy of the instance (`default`, `dedicated`, or `host`) | `string` | `"default"` | no |
| `host_id` | ID of a dedicated host the instance will be assigned to | `string` | `null` | no |
| `cpu_core_count` | Sets the number of CPU cores for an instance | `number` | `null` | no |
| `threads_per_core` | Sets the number of threads per CPU core | `number` | `null` | no |
| `iam_instance_profile` | The IAM Instance Profile name or ARN to launch the instance with | `string` | `null` | no |
| `disable_api_termination` | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| `disable_api_stop` | If true, enables EC2 Instance Stop Protection | `bool` | `false` | no |
| `instance_initiated_shutdown_behavior` | Shutdown behavior (`stop` or `terminate`) | `string` | `"stop"` | no |
| `monitoring` | If true, enables detailed CloudWatch monitoring | `bool` | `false` | no |
| `ebs_optimized` | If true, the launched EC2 instance will be EBS-optimized | `bool` | `true` | no |
| `cpu_credits` | Credit specification for T2/T3/T4g instances (`standard` or `unlimited`) | `string` | `"standard"` | no |
| `auto_recovery` | Automatic recovery behavior (`default` or `disabled`) | `string` | `"default"` | no |
| `user_data` | The user-data script to provide when launching the instance | `string` | `null` | no |
| `user_data_base64` | Base64-encoded user data | `string` | `null` | no |
| `user_data_replace_on_change` | Triggers destroy and recreate when user_data changes | `bool` | `false` | no |
| `enable_eip` | Whether to allocate and associate an Elastic IP (EIP) | `bool` | `false` | no |
| `eip_tags` | A map of tags to assign to the Elastic IP resource | `map(string)` | `{}` | no |
| `root_block_device` | Configuration block for the root block device of the instance | `object` | See `variables.tf` | no |
| `ebs_block_device` | Additional EBS volume attachments to create and mount on the instance | `list(object)` | `[]` | no |
| `metadata_options` | Customize IMDSv2 metadata options | `object` | IMDSv2 enforced | no |
| `tags` | A mapping of tags to assign to the instance and related resources | `map(string)` | `{}` | no |
| `volume_tags` | A mapping of tags to assign to all EBS volumes created directly with the instance | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the EC2 instance |
| `arn` | The ARN of the EC2 instance |
| `name` | The name given to the EC2 instance |
| `ami` | The AMI ID used to launch the EC2 instance |
| `instance_type` | The instance type of the EC2 instance |
| `availability_zone` | The availability zone of the EC2 instance |
| `placement_group` | The placement group for the EC2 instance |
| `public_ip` | The public IP address assigned to the instance (or Elastic IP if enabled) |
| `private_ip` | The private IP address assigned to the instance |
| `public_dns` | The public DNS name assigned to the instance |
| `private_dns` | The private DNS name assigned to the instance |
| `subnet_id` | The VPC Subnet ID the instance was launched in |
| `vpc_security_group_ids` | The security group IDs associated with the instance |
| `primary_network_interface_id` | The ID of the instance's primary network interface |
| `iam_instance_profile` | The IAM instance profile assigned to the instance |
| `root_block_device` | Root block device configuration and attributes |
| `ebs_block_devices` | Map of secondary EBS volumes created and attached |
| `eip_public_ip` | The Elastic IP public address if enabled |
| `eip_allocation_id` | The Elastic IP allocation ID if enabled |
