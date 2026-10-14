variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "eib" {
  description = "Map of AWS EC2 Image Builder configurations to deploy, keyed by pipeline identifier."
  type = map(object({
    name                          = optional(string, null)
    description                   = optional(string, null)
    parent_image                  = optional(string, "amazon-linux-2-x86/x.x.x")
    recipe_version                = optional(string, "1.0.0")
    components                    = optional(list(string), [])
    instance_types                = optional(list(string), ["t3.medium"])
    instance_profile_name         = optional(string, null)
    subnet_id                     = optional(string, null)
    security_group_ids            = optional(list(string), [])
    key_pair                      = optional(string, null)
    terminate_instance_on_failure = optional(bool, true)
    sns_topic_arn                 = optional(string, null)
    schedule_expression           = optional(string, null)
    pipeline_status               = optional(string, "ENABLED")
    tags                          = optional(map(string), {})
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = optional(object({
        volume_size           = optional(number, null)
        volume_type           = optional(string, null)
        delete_on_termination = optional(bool, true)
        encrypted             = optional(bool, null)
        kms_key_id            = optional(string, null)
      }), null)
    })), [])
    http_tokens                 = optional(string, null)
    http_put_response_hop_limit = optional(number, null)
    logging_s3_bucket_name      = optional(string, null)
    logging_s3_key_prefix       = optional(string, null)
    distributions = optional(list(object({
      region                        = string
      ami_name                      = optional(string, null)
      ami_description               = optional(string, null)
      ami_tags                      = optional(map(string), {})
      kms_key_id                    = optional(string, null)
      launch_permission_account_ids = optional(list(string), [])
    })), [])
  }))
  default = {}
}
