variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "ebs" {
  description = "Map of AWS EBS volume configurations to deploy, keyed by volume name."
  type = map(object({
    name                 = optional(string, null)
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
  default = {}
}
