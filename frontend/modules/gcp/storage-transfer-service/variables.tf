variable "project_id" {
  type = string
}

variable "storage_transfer_service" {
  description = "Storage Transfer Service deployments configured through the Sela Deployer catalog. Each deployment picks one source cloud, then defines a group of transfer jobs from that cloud into GCS."

  type = map(object({
    name                            = string
    grant_destination_bucket_access = optional(bool, true)

    source_type = string # "aws_s3" or "azure_blob"

    aws_jobs = optional(list(object({
      job_name    = string
      description = optional(string)
      enabled     = optional(bool, true)

      bucket_name = string
      path        = optional(string)

      auth_method = string # "role_arn" or "access_key"

      role_arn = optional(string)

      access_key_id     = optional(string)
      secret_access_key = optional(string)

      dest_gcs_bucket = string
      dest_path       = optional(string)

      include_prefixes = optional(list(string), [])
      exclude_prefixes = optional(list(string), [])

      overwrite_when                            = optional(string, "NEVER")
      delete_objects_from_source_after_transfer = optional(bool, false)
      delete_objects_unique_in_sink             = optional(bool, false)

      schedule = optional(object({
        start_date = object({
          year  = number
          month = number
          day   = number
        })
        end_date = optional(object({
          year  = number
          month = number
          day   = number
        }))
        start_time = optional(object({
          hours   = number
          minutes = number
          seconds = optional(number, 0)
        }))
        repeat_interval_days = optional(number)
      }))
    })), [])

    azure_jobs = optional(list(object({
      job_name    = string
      description = optional(string)
      enabled     = optional(bool, true)

      storage_account = string
      container       = string
      path            = optional(string)
      sas_token       = string

      dest_gcs_bucket = string
      dest_path       = optional(string)

      include_prefixes = optional(list(string), [])
      exclude_prefixes = optional(list(string), [])

      overwrite_when                            = optional(string, "NEVER")
      delete_objects_from_source_after_transfer = optional(bool, false)
      delete_objects_unique_in_sink             = optional(bool, false)

      schedule = optional(object({
        start_date = object({
          year  = number
          month = number
          day   = number
        })
        end_date = optional(object({
          year  = number
          month = number
          day   = number
        }))
        start_time = optional(object({
          hours   = number
          minutes = number
          seconds = optional(number, 0)
        }))
        repeat_interval_days = optional(number)
      }))
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) : contains(["aws_s3", "azure_blob"], sts.source_type)
    ])
    error_message = "source_type must be 'aws_s3' or 'azure_blob'."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      length(distinct(concat(
        [for j in sts.aws_jobs : j.job_name],
        [for j in sts.azure_jobs : j.job_name]
      ))) == length(sts.aws_jobs) + length(sts.azure_jobs)
    ])
    error_message = "job_name must be unique within one Storage Transfer Service deployment."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) : sts.source_type != "aws_s3" || length(sts.azure_jobs) == 0
    ])
    error_message = "A deployment with source_type 'aws_s3' cannot define azure_jobs."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) : sts.source_type != "azure_blob" || length(sts.aws_jobs) == 0
    ])
    error_message = "A deployment with source_type 'azure_blob' cannot define aws_jobs."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      alltrue([for j in sts.aws_jobs : contains(["role_arn", "access_key"], j.auth_method)])
    ])
    error_message = "aws_jobs auth_method must be 'role_arn' or 'access_key'."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      alltrue([for j in sts.aws_jobs : j.auth_method != "role_arn" || j.role_arn != null])
    ])
    error_message = "aws_jobs with auth_method 'role_arn' require role_arn."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      alltrue([for j in sts.aws_jobs : j.auth_method != "access_key" || (j.access_key_id != null && j.secret_access_key != null)])
    ])
    error_message = "aws_jobs with auth_method 'access_key' require access_key_id and secret_access_key."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      alltrue([for j in concat(sts.aws_jobs, sts.azure_jobs) : contains(["NEVER", "DIFFERENT", "ALWAYS"], j.overwrite_when)])
    ])
    error_message = "jobs overwrite_when must be 'NEVER', 'DIFFERENT', or 'ALWAYS'."
  }
}
