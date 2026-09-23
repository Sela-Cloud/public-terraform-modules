variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "ebs" {
  description = "Map of AWS EBS volume configurations to deploy, keyed by volume name."
  type = map(object({
    name                 = optional(string, "ebs-volume")
    availability_zone    = optional(string, "us-east-1a")
    size                 = optional(number, 20)
    type                 = optional(string, "gp3")
    iops                 = optional(number, null)
    throughput           = optional(number, null)
    encrypted            = optional(bool, true)
    kms_key_id           = optional(string, null)
    snapshot_id          = optional(string, null)
    multi_attach_enabled = optional(bool, false)
    final_snapshot       = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
  default = {
    "ebs-default" = {
      name                 = "ebs-default"
      availability_zone    = "us-east-1a"
      size                 = 20
      type                 = "gp3"
      iops                 = null
      throughput           = null
      encrypted            = true
      kms_key_id           = null
      snapshot_id          = null
      multi_attach_enabled = false
      final_snapshot       = false
      tags                 = {}
    }
  }
}
