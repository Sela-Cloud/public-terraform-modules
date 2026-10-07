variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "eib" {
  description = "Map of AWS EC2 Image Builder configurations to deploy, keyed by pipeline identifier."
  type = map(object({
    name                          = optional(string, "eib-default")
    description                   = optional(string, null)
    parent_image                  = optional(string, "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x")
    recipe_version                = optional(string, "1.0.0")
    components                    = optional(list(string), [])
    instance_types                = optional(list(string), ["t3.medium"])
    instance_profile_name         = optional(string, "")
    subnet_id                     = optional(string, null)
    security_group_ids            = optional(list(string), [])
    key_pair                      = optional(string, null)
    terminate_instance_on_failure = optional(bool, true)
    sns_topic_arn                 = optional(string, null)
    schedule_expression           = optional(string, null)
    pipeline_status               = optional(string, "ENABLED")
    tags                          = optional(map(string), {})
  }))
  default = {
    "eib-default" = {
      name                          = "eib-default"
      description                   = null
      parent_image                  = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
      recipe_version                = "1.0.0"
      components                    = []
      instance_types                = ["t3.medium"]
      instance_profile_name         = ""
      subnet_id                     = null
      security_group_ids            = []
      key_pair                      = null
      terminate_instance_on_failure = true
      sns_topic_arn                 = null
      schedule_expression           = null
      pipeline_status               = "ENABLED"
      tags                          = {}
    }
  }
}
