resource "google_artifact_registry_repository" "this" {
  project                = var.project_id
  repository_id          = var.repository_id
  location               = var.location
  format                 = var.format
  mode                   = "STANDARD_REPOSITORY"
  description            = var.description
  labels                 = var.labels
  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.docker_immutable_tags ? [true] : []
    content {
      immutable_tags = true
    }
  }

  dynamic "maven_config" {
    for_each = var.format == "MAVEN" && var.maven_version_policy != null ? [true] : []
    content {
      version_policy            = var.maven_version_policy
      allow_snapshot_overwrites = var.maven_allow_snapshot_overwrites
    }
  }

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.keep_count == null ? [cleanup_policies.value] : []
        content {
          tag_state             = condition.value.tag_state
          tag_prefixes          = length(condition.value.tag_prefixes) > 0 ? condition.value.tag_prefixes : null
          package_name_prefixes = length(condition.value.package_name_prefixes) > 0 ? condition.value.package_name_prefixes : null
          version_name_prefixes = length(condition.value.version_name_prefixes) > 0 ? condition.value.version_name_prefixes : null
          older_than            = condition.value.older_than
          newer_than            = condition.value.newer_than
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.keep_count != null ? [cleanup_policies.value] : []
        content {
          keep_count            = most_recent_versions.value.keep_count
          package_name_prefixes = length(most_recent_versions.value.package_name_prefixes) > 0 ? most_recent_versions.value.package_name_prefixes : null
        }
      }
    }
  }

  dynamic "vulnerability_scanning_config" {
    for_each = var.vulnerability_scanning_enablement != null ? [var.vulnerability_scanning_enablement] : []
    content {
      enablement_config = vulnerability_scanning_config.value
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "this" {
  for_each = {
    for binding in values(var.iam_bindings) : "${binding.role}|${binding.member}" => binding
  }

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this.name
  role       = each.value.role
  member     = each.value.member
}
