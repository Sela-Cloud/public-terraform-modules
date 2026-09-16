################################################################################
# AWS EBS Volume Variables
################################################################################

variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "ap-south-1"
}

variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "ebs-volume"
}

variable "availability_zone" {
  description = "The AZ where the EBS volume will exist."
  type        = string
}

variable "size" {
  description = "The size of the drive in GiBs."
  type        = number
  default     = 20
}

variable "type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1, or st1."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Required for io1, io2, and gp3 (if customized)."
  type        = number
  default     = null
}

variable "throughput" {
  description = "The throughput that the volume supports, in MiB/s. Valid only for gp3 volumes."
  type        = number
  default     = null
}

variable "encrypted" {
  description = "If true, the disk will be encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key."
  type        = string
  default     = null
}

variable "snapshot_id" {
  description = "A snapshot ID from which to create the EBS volume."
  type        = string
  default     = null
}

variable "multi_attach_enabled" {
  description = "Specifies whether to enable Amazon EBS Multi-Attach. Valid for io1 and io2 volumes."
  type        = bool
  default     = false
}

variable "final_snapshot" {
  description = "If true, snapshot will be created before deletion."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
