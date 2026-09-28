variable "project_id" {
  description = "Project where the transfer jobs and destination bucket IAM grants are created."
  type        = string
}

variable "grant_destination_bucket_access" {
  description = "Grant the project's Storage Transfer service agent roles/storage.objectAdmin on every unique destination bucket referenced by jobs."
  type        = bool
  default     = true
}

variable "grant_source_access" {
  description = <<-EOT
    For Cloud Storage sources, grant the project's Storage Transfer service agent what it needs to
    read them: roles/storage.objectViewer plus roles/storage.legacyBucketReader on each source
    bucket (legacyBucketWriter instead when a job deletes from source), and roles/pubsub.subscriber
    on the Pub/Sub subscription of each event-driven job. AWS and Azure sources authenticate with
    their own credentials and are unaffected.
  EOT
  type        = bool
  default     = true
}

variable "jobs" {
  description = <<-EOT
    Storage Transfer Service jobs, keyed by job_name. Each job copies from exactly one AWS S3, Azure
    Blob or Cloud Storage source into one Cloud Storage destination.

    Each job is triggered one of two ways, never both — the API ignores a schedule once an event
    stream is set, and the provider refuses the combination:

      trigger = "schedule"  runs on `schedule`, or once at deploy time when `schedule` is null
      trigger = "event"     runs when `event_stream` reports new or changed objects. Deletions at
                            the source are never propagated in this mode.
  EOT
  type = map(object({
    job_name    = string
    description = optional(string)
    enabled     = optional(bool, true)

    source_type = string # "aws_s3", "azure_blob" or "gcs"

    trigger = optional(string, "schedule") # "schedule" or "event"

    # Where change notifications arrive, for trigger = "event". The name's form depends on the
    # source:
    #   gcs         projects/<project>/subscriptions/<subscription>
    #   aws_s3      arn:aws:sqs:<region>:<account>:<queue>   (arn:aws-us-gov:sqs:… in GovCloud)
    #   azure_blob  <storage-account>.queue.core.windows.net/<queue>
    # Times are RFC 3339 in UTC, e.g. 2026-10-01T00:00:00Z. No start time means listen now; no
    # expiration means listen indefinitely.
    event_stream = optional(object({
      name            = string
      start_time      = optional(string)
      expiration_time = optional(string)
    }))

    gcs = optional(object({
      bucket_name = string
      path        = optional(string)
    }))

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
      for job in values(var.jobs) : contains(["aws_s3", "azure_blob", "gcs"], job.source_type)
    ])
    error_message = "jobs source_type must be 'aws_s3', 'azure_blob' or 'gcs'."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : job.source_type != "gcs" || job.gcs != null
    ])
    error_message = "jobs with source_type 'gcs' require the gcs block."
  }

  # The provider's own rule for this field, checked here so the error names the job's setting
  # rather than surfacing from the API at apply time.
  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.source_type != "gcs" || try(job.gcs.path == null || job.gcs.path == "" || endswith(job.gcs.path, "/"), false)
    ])
    error_message = "gcs.path must be empty or end with '/' — it is an object prefix, e.g. 'exports/'."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : contains(["schedule", "event"], job.trigger)
    ])
    error_message = "jobs trigger must be 'schedule' or 'event'."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) : job.trigger != "event" || job.event_stream != null
    ])
    error_message = "jobs with trigger 'event' require event_stream — where the change notifications arrive."
  }

  # Refused outright rather than one side silently winning. The API ignores the schedule once an
  # event stream is set and the provider rejects the pair; either way, a schedule someone filled
  # in would never run, and nothing would say so.
  validation {
    condition = alltrue([
      for job in values(var.jobs) : job.trigger != "event" || job.schedule == null
    ])
    error_message = "jobs with trigger 'event' cannot also have a schedule — an event-driven job runs when objects change, not on a timetable. Remove the schedule, or use trigger 'schedule'."
  }

  # The stream must be the kind this source can send. Each source reports changes through its own
  # cloud's queue, and a mismatched name fails at apply time with an API error that does not say
  # which half is wrong.
  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.trigger != "event" || job.source_type != "gcs" ||
      try(can(regex("^projects/[^/]+/subscriptions/[^/]+$", job.event_stream.name)), false)
    ])
    error_message = "event_stream.name for a Cloud Storage source must be a Pub/Sub subscription: projects/<project>/subscriptions/<subscription>."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.trigger != "event" || job.source_type != "aws_s3" ||
      try(can(regex("^arn:aws(-us-gov)?:sqs:[^:]+:[0-9]{12}:[^:]+$", job.event_stream.name)), false)
    ])
    error_message = "event_stream.name for an AWS S3 source must be an SQS queue ARN: arn:aws:sqs:<region>:<account>:<queue>."
  }

  validation {
    condition = alltrue([
      for job in values(var.jobs) :
      job.trigger != "event" || job.source_type != "azure_blob" ||
      try(can(regex("^[a-z0-9]+\\.queue\\.core\\.windows\\.net/[^/]+$", job.event_stream.name)), false)
    ])
    error_message = "event_stream.name for an Azure Blob source must be a storage queue: <storage-account>.queue.core.windows.net/<queue>."
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
