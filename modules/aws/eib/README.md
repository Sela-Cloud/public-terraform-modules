# AWS EC2 Image Builder Terraform Module

This module provisions an AWS EC2 Image Builder Pipeline, Image Recipe, and Infrastructure Configuration to automate the creation of golden AMIs.

## Usage

### Basic Usage

```hcl
module "image_builder" {
  source = "../../modules/aws/eib"

  name                  = "golden-ami-pipeline"
  parent_image          = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
  instance_profile_name = "EC2ImageBuilderInstanceProfile"
  subnet_id             = "subnet-0123456789abcdef0"
  security_group_ids    = ["sg-0123456789abcdef0"]

  components = [
    "arn:aws:imagebuilder:us-east-1:aws:component/update-linux/x.x.x"
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Scheduled Pipeline

```hcl
module "image_builder" {
  source = "../../modules/aws/eib"

  name                  = "weekly-golden-image"
  parent_image          = "ami-0c55b159cbfafe1f0"
  instance_profile_name = "EC2ImageBuilderInstanceProfile"
  instance_types        = ["t3.medium"]
  subnet_id             = "subnet-0123456789abcdef0"
  sns_topic_arn         = "arn:aws:sns:us-east-1:123456789012:build-notifications"

  schedule_expression = "cron(0 0 ? * SUN *)"

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Base name to be used on all Image Builder resources | `string` | `"eib-default"` | no |
| `description` | Description for Image Builder resources | `string` | `null` | no |
| `parent_image` | Parent image AMI ID or base image ARN | `string` | `"arn:aws:imagebuilder:..."` | no |
| `recipe_version` | Version of the image recipe | `string` | `"1.0.0"` | no |
| `components` | List of Image Builder component ARNs. AWS requires at least one | `list(string)` | `[]` | no |
| `instance_types` | List of EC2 instance types for build instance | `list(string)` | `["t3.medium"]` | no |
| `instance_profile_name` | IAM instance profile name. Required by AWS | `string` | `null` | no |
| `subnet_id` | Subnet ID for the build instance | `string` | `null` | no |
| `security_group_ids` | List of security group IDs | `list(string)` | `[]` | no |
| `key_pair` | Key pair name for build instance | `string` | `null` | no |
| `terminate_instance_on_failure` | Whether to terminate build instance on failure | `bool` | `true` | no |
| `sns_topic_arn` | SNS topic ARN for build notifications | `string` | `null` | no |
| `schedule_expression` | Cron or rate schedule expression | `string` | `null` | no |
| `pipeline_status` | Status of image pipeline (`ENABLED`, `DISABLED`) | `string` | `"ENABLED"` | no |
| `tags` | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| `block_device_mappings` | Customize block device mappings (e.g. root volume size) for the output AMI | `list(object)` | `[]` | no |
| `http_tokens` | Whether IMDSv2 is required on build instances (`optional`, `required`) | `string` | `null` | no |
| `http_put_response_hop_limit` | HTTP PUT response hop limit for build instance metadata | `number` | `null` | no |
| `logging_s3_bucket_name` | S3 bucket to store build logs | `string` | `null` | no |
| `logging_s3_key_prefix` | S3 key prefix for build logs | `string` | `null` | no |
| `distributions` | Per-region AMI distribution settings (sharing, copying, tagging) | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `pipeline_id` | The ID of the Image Builder pipeline |
| `pipeline_arn` | The ARN of the Image Builder pipeline |
| `pipeline_name` | The name of the Image Builder pipeline |
| `recipe_arn` | The ARN of the Image Recipe |
| `recipe_id` | The ID of the Image Recipe |
| `infrastructure_configuration_arn` | The ARN of the Infrastructure Configuration |
| `infrastructure_configuration_id` | The ID of the Infrastructure Configuration |
| `distribution_configuration_arn` | The ARN of the Distribution Configuration, if configured |
| `distribution_configuration_id` | The ID of the Distribution Configuration, if configured |
