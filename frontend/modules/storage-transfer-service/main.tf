locals {
  deployments = {
    for key, sts in var.storage_transfer_service : key => merge(sts, {
      jobs = merge(
        {
          for j in sts.aws_jobs : j.job_name => {
            job_name    = j.job_name
            description = j.description
            enabled     = j.enabled
            source_type = "aws_s3"
            aws_s3 = {
              bucket_name       = j.bucket_name
              path              = j.path
              auth_method       = j.auth_method
              role_arn          = j.role_arn
              access_key_id     = j.access_key_id
              secret_access_key = j.secret_access_key
            }
            azure_blob                                = null
            dest_gcs_bucket                           = j.dest_gcs_bucket
            dest_path                                 = j.dest_path
            include_prefixes                          = j.include_prefixes
            exclude_prefixes                          = j.exclude_prefixes
            overwrite_when                            = j.overwrite_when
            delete_objects_from_source_after_transfer = j.delete_objects_from_source_after_transfer
            delete_objects_unique_in_sink             = j.delete_objects_unique_in_sink
            schedule                                  = j.schedule
          }
        },
        {
          for j in sts.azure_jobs : j.job_name => {
            job_name    = j.job_name
            description = j.description
            enabled     = j.enabled
            source_type = "azure_blob"
            aws_s3      = null
            azure_blob = {
              storage_account = j.storage_account
              container       = j.container
              path            = j.path
              sas_token       = j.sas_token
            }
            dest_gcs_bucket                           = j.dest_gcs_bucket
            dest_path                                 = j.dest_path
            include_prefixes                          = j.include_prefixes
            exclude_prefixes                          = j.exclude_prefixes
            overwrite_when                            = j.overwrite_when
            delete_objects_from_source_after_transfer = j.delete_objects_from_source_after_transfer
            delete_objects_unique_in_sink             = j.delete_objects_unique_in_sink
            schedule                                  = j.schedule
          }
        }
      )
    })
  }
}

module "storage_transfer_service" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/storage-transfer-service?ref=v0.6.16"
  for_each = local.deployments

  project_id                      = var.project_id
  grant_destination_bucket_access = each.value.grant_destination_bucket_access
  jobs                            = each.value.jobs
}
