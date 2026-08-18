variable "project_id" {
  description = "GCP Project ID that owns the parent Cloud SQL instance."
  type        = string
}

variable "cloud_sql_user" {
  description = "Cloud SQL IAM database users configured through the Sela Deployer catalog. One map entry is exactly one database user on an existing Cloud SQL instance, so a user can be revoked without touching its instance or its sibling users."
  type = map(object({
    user_key        = string
    instance_name   = string
    engine          = string
    name            = string
    type            = string
    iam_member      = string
    deletion_policy = optional(string, "ABANDON")
  }))
  default = {}

  validation {
    condition = alltrue([
      for user in values(var.cloud_sql_user) :
      trimspace(user.instance_name) != ""
    ])
    error_message = "Every Cloud SQL user must name the Cloud SQL instance it is created on."
  }

  validation {
    condition = alltrue([
      for user in values(var.cloud_sql_user) :
      contains(["CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT"], user.type)
    ])
    error_message = "Cloud SQL Phase 1 supports CLOUD_IAM_USER and CLOUD_IAM_SERVICE_ACCOUNT users only."
  }

  validation {
    condition = alltrue([
      for user in values(var.cloud_sql_user) :
      contains(["postgres", "mysql"], user.engine)
    ])
    error_message = "Cloud SQL engine must be postgres or mysql."
  }

  validation {
    condition = alltrue([
      for user in values(var.cloud_sql_user) :
      user.engine != "mysql" || (!strcontains(user.name, "@") && length(user.name) <= 32)
    ])
    error_message = "MySQL IAM database usernames must be the local email part only, without @domain, and must not exceed 32 characters."
  }

  validation {
    condition = alltrue([
      for user in values(var.cloud_sql_user) :
      contains(["ABANDON", "DELETE"], user.deletion_policy)
    ])
    error_message = "Cloud SQL user deletion policy must be ABANDON or DELETE."
  }
}
