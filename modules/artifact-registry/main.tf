resource "google_artifact_registry_repository" "this" {
  project                = var.project_id
  repository_id          = var.repository_id
  location               = var.location
  format                 = var.format
  mode                   = var.mode
  kms_key_name           = var.kms_key_name
  description            = var.description
  labels                 = var.labels
  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "docker_config" {
    for_each = var.mode == "STANDARD_REPOSITORY" && var.format == "DOCKER" && var.docker_immutable_tags ? [true] : []
    content {
      immutable_tags = true
    }
  }

  dynamic "maven_config" {
    for_each = var.mode == "STANDARD_REPOSITORY" && var.format == "MAVEN" && var.maven_version_policy != null ? [true] : []
    content {
      version_policy            = var.maven_version_policy
      allow_snapshot_overwrites = var.maven_allow_snapshot_overwrites
    }
  }

  dynamic "virtual_repository_config" {
    for_each = var.mode == "VIRTUAL_REPOSITORY" ? [true] : []
    content {
      dynamic "upstream_policies" {
        for_each = var.virtual_upstream_policies
        content {
          id         = upstream_policies.value.id
          repository = upstream_policies.value.repository
          priority   = upstream_policies.value.priority
        }
      }
    }
  }

  dynamic "remote_repository_config" {
    for_each = var.mode == "REMOTE_REPOSITORY" ? [true] : []
    content {
      disable_upstream_validation = var.disable_upstream_validation

      dynamic "common_repository" {
        for_each = var.remote_upstream == "CUSTOM" ? [var.remote_custom_uri] : []
        content { uri = common_repository.value }
      }

      dynamic "docker_repository" {
        for_each = var.format == "DOCKER" && var.remote_upstream != "CUSTOM" ? [true] : []
        content { public_repository = "DOCKER_HUB" }
      }
      dynamic "maven_repository" {
        for_each = var.format == "MAVEN" && var.remote_upstream != "CUSTOM" ? [true] : []
        content { public_repository = "MAVEN_CENTRAL" }
      }
      dynamic "npm_repository" {
        for_each = var.format == "NPM" && var.remote_upstream != "CUSTOM" ? [true] : []
        content { public_repository = "NPMJS" }
      }
      dynamic "python_repository" {
        for_each = var.format == "PYTHON" && var.remote_upstream != "CUSTOM" ? [true] : []
        content { public_repository = "PYPI" }
      }
      dynamic "apt_repository" {
        for_each = var.format == "APT" && var.remote_upstream != "CUSTOM" ? [true] : []
        content {
          public_repository {
            repository_base = var.remote_apt_repository_base
            repository_path = var.remote_apt_repository_path
          }
        }
      }
      dynamic "yum_repository" {
        for_each = var.format == "YUM" && var.remote_upstream != "CUSTOM" ? [true] : []
        content {
          public_repository {
            repository_base = var.remote_yum_repository_base
            repository_path = var.remote_yum_repository_path
          }
        }
      }

      dynamic "upstream_credentials" {
        for_each = var.remote_credentials_username != null ? [true] : []
        content {
          username_password_credentials {
            username                = var.remote_credentials_username
            password_secret_version = var.remote_password_secret_version
          }
        }
      }
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
