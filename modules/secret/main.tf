resource "google_secret_manager_secret" "this" {
  project             = var.project_id
  secret_id           = var.secret_id
  labels              = var.labels
  annotations         = var.annotations
  deletion_protection = var.deletion_protection
  expire_time         = var.expire_time
  version_destroy_ttl = var.version_destroy_ttl

  replication {
    dynamic "auto" {
      for_each = var.custom_replication ? [] : [""]
      content {
        dynamic "customer_managed_encryption" {
          for_each = var.kms_key_name == null ? [] : [""]
          content {
            kms_key_name = var.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = var.custom_replication ? [""] : []
      content {
        dynamic "replicas" {
          for_each = var.replica_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = var.set_rotation ? [""] : []
    content {
      rotation_period    = var.rotation_period
      next_rotation_time = var.next_rotation_time
    }
  }

  dynamic "topics" {
    for_each = var.topics
    content {
      name = topics.value
    }
  }

  lifecycle {
    precondition {
      condition     = var.custom_replication || length(var.replica_locations) == 0
      error_message = "replica_locations is only used when custom_replication is true."
    }
    precondition {
      condition     = !var.custom_replication || length(var.replica_locations) > 0
      error_message = "At least one replica location is required when custom_replication is true."
    }
    precondition {
      condition     = !var.set_rotation || (var.rotation_period != null && var.next_rotation_time != null)
      error_message = "rotation_period and next_rotation_time are required when set_rotation is true."
    }
  }
}
