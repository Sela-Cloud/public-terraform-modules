variable "project_id" {
  type = string
}

variable "storage_transfer_service" {
  description = "Storage Transfer Service deployments configured through the Sela Deployer catalog. Each deployment picks one source — AWS S3, Azure Blob or Cloud Storage — then defines a group of transfer jobs from it into Cloud Storage, each either scheduled or event-driven."

  type = map(object({
    name                            = string
    grant_destination_bucket_access = optional(bool, true)
    grant_source_access             = optional(bool, true)

    source_type = string # "aws_s3", "azure_blob" or "gcs"

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

      # "schedule" runs on `schedule` (or once at deploy time without one); "event" runs when
      # `event_stream` reports new or changed objects. Never both.
      trigger = optional(string, "schedule")
      event_stream = optional(object({
        name            = string
        start_time      = optional(string)
        expiration_time = optional(string)
      }))

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

      # "schedule" runs on `schedule` (or once at deploy time without one); "event" runs when
      # `event_stream` reports new or changed objects. Never both.
      trigger = optional(string, "schedule")
      event_stream = optional(object({
        name            = string
        start_time      = optional(string)
        expiration_time = optional(string)
      }))

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

    gcs_jobs = optional(list(object({
      job_name    = string
      description = optional(string)
      enabled     = optional(bool, true)

      bucket_name = string
      path        = optional(string) # empty, or a prefix ending in "/"

      dest_gcs_bucket = string
      dest_path       = optional(string)

      include_prefixes = optional(list(string), [])
      exclude_prefixes = optional(list(string), [])

      overwrite_when                            = optional(string, "NEVER")
      delete_objects_from_source_after_transfer = optional(bool, false)
      delete_objects_unique_in_sink             = optional(bool, false)

      # "schedule" runs on `schedule` (or once at deploy time without one); "event" runs when
      # `event_stream` reports new or changed objects. Never both.
      trigger = optional(string, "schedule")
      event_stream = optional(object({
        name            = string
        start_time      = optional(string)
        expiration_time = optional(string)
      }))

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
      for sts in values(var.storage_transfer_service) : contains(["aws_s3", "azure_blob", "gcs"], sts.source_type)
    ])
    error_message = "source_type must be 'aws_s3', 'azure_blob' or 'gcs'."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      length(distinct(concat(
        [for j in sts.aws_jobs : j.job_name],
        [for j in sts.azure_jobs : j.job_name],
        [for j in sts.gcs_jobs : j.job_name]
      ))) == length(sts.aws_jobs) + length(sts.azure_jobs) + length(sts.gcs_jobs)
    ])
    error_message = "job_name must be unique within one Storage Transfer Service deployment."
  }

  # One job list per deployment, the one matching source_type. Generalised from two pairwise
  # rules, which would have needed a third and fourth for the Cloud Storage source.
  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      (sts.source_type == "aws_s3" || length(sts.aws_jobs) == 0) &&
      (sts.source_type == "azure_blob" || length(sts.azure_jobs) == 0) &&
      (sts.source_type == "gcs" || length(sts.gcs_jobs) == 0)
    ])
    error_message = "A deployment defines only the job list matching its source_type: aws_jobs for 'aws_s3', azure_jobs for 'azure_blob', gcs_jobs for 'gcs'."
  }

  validation {
    condition = alltrue([
      for sts in values(var.storage_transfer_service) :
      alltrue([for j in concat(sts.aws_jobs, sts.azure_jobs, sts.gcs_jobs) : contains(["schedule", "event"], j.trigger)])
    ])
    error_message = "jobs trigger must be 'schedule' or 'event'."
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
      alltrue([for j in concat(sts.aws_jobs, sts.azure_jobs, sts.gcs_jobs) : contains(["NEVER", "DIFFERENT", "ALWAYS"], j.overwrite_when)])
    ])
    error_message = "jobs overwrite_when must be 'NEVER', 'DIFFERENT', or 'ALWAYS'."
  }
}
