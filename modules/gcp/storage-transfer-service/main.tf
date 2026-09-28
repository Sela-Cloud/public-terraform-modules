data "google_storage_transfer_project_service_account" "this" {
  project = var.project_id
}

locals {
  destination_buckets = toset([for job in values(var.jobs) : job.dest_gcs_bucket])

  # Cloud Storage source buckets, each mapped to whether any job deletes from it. The bucket-level
  # role depends on that: legacyBucketReader is enough to read, but deleting from source after the
  # transfer needs legacyBucketWriter.
  gcs_sources = {
    for bucket in distinct([for job in values(var.jobs) : job.gcs.bucket_name if job.source_type == "gcs"]) :
    bucket => anytrue([
      for job in values(var.jobs) :
      job.delete_objects_from_source_after_transfer if job.source_type == "gcs" && job.gcs.bucket_name == bucket
    ])
  }

  # Pub/Sub subscriptions the agent must consume, one per event-driven Cloud Storage job. AWS and
  # Azure queues are read with the job's own credentials, so nothing is granted for those here.
  gcs_event_subscriptions = toset([
    for job in values(var.jobs) : job.event_stream.name
    if job.trigger == "event" && job.source_type == "gcs"
  ])
}

resource "google_storage_bucket_iam_member" "sts_agent" {
  for_each = var.grant_destination_bucket_access ? local.destination_buckets : []

  bucket = each.value
  role   = "roles/storage.objectAdmin"
  member = data.google_storage_transfer_project_service_account.this.member
}

resource "google_storage_bucket_iam_member" "sts_source_objects" {
  for_each = var.grant_source_access ? local.gcs_sources : {}

  bucket = each.key
  role   = "roles/storage.objectViewer"
  member = data.google_storage_transfer_project_service_account.this.member
}

resource "google_storage_bucket_iam_member" "sts_source_bucket" {
  for_each = var.grant_source_access ? local.gcs_sources : {}

  bucket = each.key
  role   = each.value ? "roles/storage.legacyBucketWriter" : "roles/storage.legacyBucketReader"
  member = data.google_storage_transfer_project_service_account.this.member
}

resource "google_pubsub_subscription_iam_member" "sts_events" {
  for_each = var.grant_source_access ? local.gcs_event_subscriptions : []

  # Split from projects/<project>/subscriptions/<name> rather than passed whole, so the grant is
  # unambiguous either way — and so a subscription in another project is granted in *that* project.
  project      = split("/", each.value)[1]
  subscription = split("/", each.value)[3]
  role         = "roles/pubsub.subscriber"
  member       = data.google_storage_transfer_project_service_account.this.member
}

resource "google_storage_transfer_job" "this" {
  for_each = var.jobs

  project     = var.project_id
  description = coalesce(each.value.description, each.value.job_name)
  status      = each.value.enabled ? "ENABLED" : "DISABLED"

  transfer_spec {
    dynamic "aws_s3_data_source" {
      for_each = each.value.source_type == "aws_s3" ? [each.value.aws_s3] : []
      content {
        bucket_name = aws_s3_data_source.value.bucket_name
        path        = aws_s3_data_source.value.path
        role_arn    = aws_s3_data_source.value.auth_method == "role_arn" ? aws_s3_data_source.value.role_arn : null

        dynamic "aws_access_key" {
          for_each = aws_s3_data_source.value.auth_method == "access_key" ? [1] : []
          content {
            access_key_id     = aws_s3_data_source.value.access_key_id
            secret_access_key = aws_s3_data_source.value.secret_access_key
          }
        }
      }
    }

    dynamic "azure_blob_storage_data_source" {
      for_each = each.value.source_type == "azure_blob" ? [each.value.azure_blob] : []
      content {
        storage_account = azure_blob_storage_data_source.value.storage_account
        container       = azure_blob_storage_data_source.value.container
        path            = azure_blob_storage_data_source.value.path

        azure_credentials {
          sas_token = azure_blob_storage_data_source.value.sas_token
        }
      }
    }

    dynamic "gcs_data_source" {
      for_each = each.value.source_type == "gcs" ? [each.value.gcs] : []
      content {
        bucket_name = gcs_data_source.value.bucket_name
        path        = gcs_data_source.value.path
      }
    }

    gcs_data_sink {
      bucket_name = each.value.dest_gcs_bucket
      path        = each.value.dest_path
    }

    dynamic "object_conditions" {
      for_each = (length(each.value.include_prefixes) > 0 || length(each.value.exclude_prefixes) > 0) ? [1] : []
      content {
        include_prefixes = each.value.include_prefixes
        exclude_prefixes = each.value.exclude_prefixes
      }
    }

    transfer_options {
      overwrite_when                            = each.value.overwrite_when
      delete_objects_from_source_after_transfer = each.value.delete_objects_from_source_after_transfer
      delete_objects_unique_in_sink             = each.value.delete_objects_unique_in_sink
    }
  }

  # Exactly one of `schedule` and `event_stream`, chosen by `trigger`. The provider refuses both;
  # the variable's validation refuses the combination earlier, with an error naming the job.
  dynamic "event_stream" {
    for_each = each.value.trigger == "event" ? [each.value.event_stream] : []
    content {
      name                         = event_stream.value.name
      event_stream_start_time      = event_stream.value.start_time
      event_stream_expiration_time = event_stream.value.expiration_time
    }
  }

  dynamic "schedule" {
    for_each = each.value.trigger == "schedule" && each.value.schedule != null ? [each.value.schedule] : []
    content {
      repeat_interval = schedule.value.repeat_interval_days != null ? "${schedule.value.repeat_interval_days * 86400}s" : null

      schedule_start_date {
        year  = schedule.value.start_date.year
        month = schedule.value.start_date.month
        day   = schedule.value.start_date.day
      }

      dynamic "schedule_end_date" {
        for_each = schedule.value.end_date != null ? [schedule.value.end_date] : []
        content {
          year  = schedule_end_date.value.year
          month = schedule_end_date.value.month
          day   = schedule_end_date.value.day
        }
      }

      dynamic "start_time_of_day" {
        for_each = schedule.value.start_time != null ? [schedule.value.start_time] : []
        content {
          hours   = start_time_of_day.value.hours
          minutes = start_time_of_day.value.minutes
          seconds = start_time_of_day.value.seconds
          nanos   = 0
        }
      }
    }
  }

  # Access before the job: a job created ahead of its grants starts, fails with a permission error
  # on its first run, and for an event-driven job may miss the notifications that arrived meanwhile.
  depends_on = [
    google_storage_bucket_iam_member.sts_agent,
    google_storage_bucket_iam_member.sts_source_objects,
    google_storage_bucket_iam_member.sts_source_bucket,
    google_pubsub_subscription_iam_member.sts_events,
  ]
}
