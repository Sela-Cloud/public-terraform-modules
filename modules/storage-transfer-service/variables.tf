variable "project_id" {
  description = "Project where the transfer jobs and destination bucket IAM grants are created."
  type        = string
}

variable "grant_destination_bucket_access" {
  description = "Grant the project's Storage Transfer service agent roles/storage.objectAdmin on every unique destination bucket referenced by jobs."
  type        = bool
  default     = true
}

variable "jobs" {
  description = "Storage Transfer Service jobs, keyed by job_name. Each job copies from exactly one AWS S3 or Azure Blob source into one GCS destination."
  type = map(object({
    job_name    = string
    description = optional(string)
    enabled     = optional(bool, true)

    source_type = string # "aws_s3" or "azure_blob"

    aws_s3 = optional(object({
      bucket_name = string
      path        = optional(string)

      auth_method = string # "role_arn" or "access_key"

      role_arn = optional(string)

      access_key_id     = optional(string)
      secret_access_key = optional(string)
    }))

    azure_blob = optional(object({
      storage_account = string
      container       = string
      path            = optional(string)
      sas_token       = string
    }))

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
  }))
  default = {}

  validation {
    condition = alltrue([
      for job in values(var.jobs) : contains(["aws_s3", "azure_blob"], job.source_type)
    ])
    error_message = "jobs source_type must be 'aws_s3' or 'azure_blob'."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : job.source_type != "aws_s3" || job.aws_s3 != null
    ])
    error_message = "jobs with source_type 'aws_s3' require the aws_s3 block."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.source_type != "aws_s3" || contains(["role_arn", "access_key"], job.aws_s3.auth_method)
    ])
    error_message = "aws_s3.auth_method must be 'role_arn' or 'access_key'."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.source_type != "aws_s3" || job.aws_s3.auth_method != "role_arn" || job.aws_s3.role_arn != null
    ])
    error_message = "aws_s3 with auth_method 'role_arn' requires role_arn."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.source_type != "aws_s3" || job.aws_s3.auth_method != "access_key" || (job.aws_s3.access_key_id != null && job.aws_s3.secret_access_key != null)
    ])
    error_message = "aws_s3 with auth_method 'access_key' requires access_key_id and secret_access_key."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : job.source_type != "azure_blob" || job.azure_blob != null
    ])
    error_message = "jobs with source_type 'azure_blob' require the azure_blob block."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : contains(["NEVER", "DIFFERENT", "ALWAYS"], job.overwrite_when)
    ])
    error_message = "jobs overwrite_when must be 'NEVER', 'DIFFERENT', or 'ALWAYS'."
  }
}
