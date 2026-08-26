data "google_storage_transfer_project_service_account" "this" {
  project = var.project_id
}

locals {
  destination_buckets = toset([for job in values(var.jobs) : job.dest_gcs_bucket])
}

resource "google_storage_bucket_iam_member" "sts_agent" {
  for_each = var.grant_destination_bucket_access ? local.destination_buckets : []

  bucket = each.value
  role   = "roles/storage.objectAdmin"
  member = data.google_storage_transfer_project_service_account.this.member
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

  dynamic "schedule" {
    for_each = each.value.schedule != null ? [each.value.schedule] : []
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

  depends_on = [google_storage_bucket_iam_member.sts_agent]
}
