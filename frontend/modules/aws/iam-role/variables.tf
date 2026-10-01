variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "iam_role" {
  description = "Map of AWS IAM Role configurations to deploy, keyed by role name."
  type = map(object({
    name                  = optional(string, "iam-role-default")
    name_prefix           = optional(string, null)
    assume_role_policy    = optional(string, "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      }\n    }\n  ]\n}")
    description           = optional(string, "Managed by Terraform")
    path                  = optional(string, "/")
    force_detach_policies = optional(bool, false)
    max_session_duration  = optional(number, 3600)
    permissions_boundary  = optional(string, null)
    managed_policy_arns   = optional(list(string), [])
    inline_policy = optional(list(object({
      name   = string
      policy = string
    })), [])
    tags                       = optional(map(string), {})
    trusted_entity_type        = optional(string, "CUSTOM_JSON")
    trusted_service_principals = optional(list(string), [])
    trusted_account_ids        = optional(list(string), [])
    trusted_role_arns          = optional(list(string), [])
    trusted_user_arns          = optional(list(string), [])
    trusted_external_id        = optional(string, null)
  }))
  default = {
    "iam-role-default" = {
      name                       = "iam-role-default"
      name_prefix                = null
      assume_role_policy         = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      }\n    }\n  ]\n}"
      description                = "Managed by Terraform"
      path                       = "/"
      force_detach_policies      = false
      max_session_duration       = 3600
      permissions_boundary       = null
      managed_policy_arns        = []
      inline_policy              = []
      tags                       = {}
      trusted_entity_type        = "CUSTOM_JSON"
      trusted_service_principals = []
      trusted_account_ids        = []
      trusted_role_arns          = []
      trusted_user_arns          = []
      trusted_external_id        = null
    }
  }

  validation {
    condition = alltrue([
      for r in values(var.iam_role) : r.trusted_entity_type == null || contains(["AWS_SERVICE", "AWS_ACCOUNT", "IAM_PRINCIPAL", "CUSTOM_JSON"], r.trusted_entity_type)
    ])
    error_message = "trusted_entity_type must be 'AWS_SERVICE', 'AWS_ACCOUNT', 'IAM_PRINCIPAL', 'CUSTOM_JSON', or null."
  }

  validation {
    condition = alltrue([
      for r in values(var.iam_role) : r.trusted_entity_type != "AWS_SERVICE" || length(r.trusted_service_principals) > 0
    ])
    error_message = "trusted_service_principals is required when trusted_entity_type is AWS_SERVICE."
  }

  validation {
    condition = alltrue([
      for r in values(var.iam_role) : r.trusted_entity_type != "AWS_ACCOUNT" || length(r.trusted_account_ids) > 0
    ])
    error_message = "trusted_account_ids is required when trusted_entity_type is AWS_ACCOUNT."
  }

  validation {
    condition = alltrue([
      for r in values(var.iam_role) :
      r.trusted_entity_type != "IAM_PRINCIPAL" || (length(r.trusted_role_arns) > 0 || length(r.trusted_user_arns) > 0)
    ])
    error_message = "At least one of trusted_role_arns or trusted_user_arns is required when trusted_entity_type is IAM_PRINCIPAL."
  }
}
