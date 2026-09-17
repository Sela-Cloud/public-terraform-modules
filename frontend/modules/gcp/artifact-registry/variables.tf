variable "project_id" {
  type = string
}

variable "artifact_registry" {
  type = map(object({
    repository_id                   = string
    location                        = string
    format                          = string
    mode                            = optional(string, "STANDARD_REPOSITORY")
    kms_key_name                    = optional(string)
    description                     = optional(string)
    labels                          = optional(map(string), {})
    docker_immutable_tags           = optional(bool, false)
    maven_version_policy            = optional(string)
    maven_allow_snapshot_overwrites = optional(bool, false)
    remote_upstream                 = optional(string)
    remote_custom_uri               = optional(string)
    remote_apt_repository_base      = optional(string)
    remote_apt_repository_path      = optional(string)
    remote_yum_repository_base      = optional(string)
    remote_yum_repository_path      = optional(string)
    remote_credentials_username     = optional(string)
    remote_password_secret_version  = optional(string)
    disable_upstream_validation     = optional(bool, false)
    virtual_upstream_policies = optional(list(object({
      id         = string
      repository = string
      priority   = number
    })), [])
    cleanup_policy_dry_run            = optional(bool, true)
    vulnerability_scanning_enablement = optional(string)
    cleanup_policies = optional(list(object({
      id                    = string
      action                = string
      tag_state             = optional(string, "ANY")
      tag_prefixes          = optional(list(string), [])
      package_name_prefixes = optional(list(string), [])
      version_name_prefixes = optional(list(string), [])
      older_than            = optional(string)
      newer_than            = optional(string)
      keep_count            = optional(number)
    })), [])
    iam_bindings = optional(list(object({
      role   = string
      member = string
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "GENERIC", "APT", "YUM"], repository.format) && contains(["STANDARD_REPOSITORY", "REMOTE_REPOSITORY", "VIRTUAL_REPOSITORY"], repository.mode)
    ])
    error_message = "Artifact Registry must use a supported format and STANDARD_REPOSITORY, REMOTE_REPOSITORY, or VIRTUAL_REPOSITORY mode."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      try(trimspace(repository.kms_key_name), "") == "" || startswith(repository.kms_key_name, "projects/${var.project_id}/locations/${repository.location}/keyRings/")
    ])
    error_message = "CMEK keys must be in the same project and location as the Artifact Registry repository."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode != "STANDARD_REPOSITORY" || contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "GENERIC"], repository.format)
    ])
    error_message = "Standard repositories support DOCKER, MAVEN, NPM, PYTHON, and GENERIC formats in this catalog."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode != "REMOTE_REPOSITORY" || contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM"], repository.format)
    ])
    error_message = "Remote repositories support DOCKER, MAVEN, NPM, PYTHON, APT, and YUM formats."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode != "VIRTUAL_REPOSITORY" || (
        contains(["DOCKER", "MAVEN", "NPM", "PYTHON"], repository.format) &&
        length(repository.virtual_upstream_policies) > 0 &&
        length(distinct([for policy in repository.virtual_upstream_policies : policy.id])) == length(repository.virtual_upstream_policies) &&
        length(distinct([for policy in repository.virtual_upstream_policies : policy.priority])) == length(repository.virtual_upstream_policies) &&
        alltrue([for policy in repository.virtual_upstream_policies : startswith(policy.repository, "projects/${var.project_id}/locations/${repository.location}/repositories/")])
      )
    ])
    error_message = "Virtual repositories require one or more uniquely identified, uniquely prioritized upstream repositories in the same project and location."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode != "REMOTE_REPOSITORY" || (
        try(trimspace(repository.remote_upstream), "") != "" &&
        ((repository.format == "DOCKER" && contains(["DOCKER_HUB", "CUSTOM"], repository.remote_upstream)) ||
          (repository.format == "MAVEN" && contains(["MAVEN_CENTRAL", "CUSTOM"], repository.remote_upstream)) ||
          (repository.format == "NPM" && contains(["NPMJS", "CUSTOM"], repository.remote_upstream)) ||
          (repository.format == "PYTHON" && contains(["PYPI", "CUSTOM"], repository.remote_upstream)) ||
          (repository.format == "APT" && contains(["APT", "CUSTOM"], repository.remote_upstream)) ||
        (repository.format == "YUM" && contains(["YUM", "CUSTOM"], repository.remote_upstream))) &&
        ((repository.remote_upstream == "CUSTOM" && try(trimspace(repository.remote_custom_uri), "") != "") ||
        (repository.remote_upstream != "CUSTOM" && try(trimspace(repository.remote_custom_uri), "") == "")) &&
        ((repository.format == "APT" && repository.remote_upstream != "CUSTOM" && try(trimspace(repository.remote_apt_repository_base), "") != "" && try(trimspace(repository.remote_apt_repository_path), "") != "") || repository.format != "APT" || repository.remote_upstream == "CUSTOM") &&
        ((repository.format == "YUM" && repository.remote_upstream != "CUSTOM" && try(trimspace(repository.remote_yum_repository_base), "") != "" && try(trimspace(repository.remote_yum_repository_path), "") != "") || repository.format != "YUM" || repository.remote_upstream == "CUSTOM") &&
        ((try(trimspace(repository.remote_credentials_username), "") == "") == (try(trimspace(repository.remote_password_secret_version), "") == ""))
      )
    ])
    error_message = "Remote repositories need an upstream; CUSTOM needs a URI, APT/YUM need base and path, and upstream credentials require both username and Secret Manager version."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode == "REMOTE_REPOSITORY" || (
        try(trimspace(repository.remote_upstream), "") == "" &&
        try(trimspace(repository.remote_custom_uri), "") == "" &&
        try(trimspace(repository.remote_credentials_username), "") == "" &&
        try(trimspace(repository.remote_password_secret_version), "") == ""
      )
    ])
    error_message = "Remote settings are valid only for remote repositories."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.mode == "VIRTUAL_REPOSITORY" || length(repository.virtual_upstream_policies) == 0
    ])
    error_message = "Virtual upstream policies are valid only for virtual repositories."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      repository.maven_version_policy == null || contains(["VERSION_POLICY_UNSPECIFIED", "RELEASE", "SNAPSHOT"], repository.maven_version_policy)
    ])
    error_message = "Maven version policy must be VERSION_POLICY_UNSPECIFIED, RELEASE, or SNAPSHOT."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      try(trimspace(repository.vulnerability_scanning_enablement), "") == "" || contains(["INHERITED", "DISABLED"], repository.vulnerability_scanning_enablement)
    ])
    error_message = "Vulnerability scanning must be INHERITED or DISABLED when configured."
  }

  validation {
    condition = alltrue(flatten([
      for repository in values(var.artifact_registry) : [
        for policy in repository.cleanup_policies :
        contains(["DELETE", "KEEP"], policy.action) &&
        contains(["ANY", "TAGGED", "UNTAGGED"], policy.tag_state) &&
        (length(policy.tag_prefixes) == 0 || policy.tag_state == "TAGGED") &&
        (policy.action == "KEEP" || policy.keep_count == null) &&
        (policy.keep_count == null || (try(length(policy.older_than), 0) == 0 && try(length(policy.newer_than), 0) == 0 && length(policy.tag_prefixes) == 0 && length(policy.version_name_prefixes) == 0))
      ]
    ]))
    error_message = "Cleanup policies require DELETE or KEEP; tag prefixes require TAGGED, and most-recent version policies use KEEP with keep_count only."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      length(distinct([for policy in repository.cleanup_policies : policy.id])) == length(repository.cleanup_policies)
    ])
    error_message = "Cleanup policy IDs must be unique within each Artifact Registry repository."
  }

  validation {
    condition = alltrue([
      for repository in values(var.artifact_registry) :
      length(distinct([for binding in repository.iam_bindings : "${binding.role}|${binding.member}"])) == length(repository.iam_bindings)
    ])
    error_message = "Each Artifact Registry IAM role and member pair must be unique within its repository."
  }
}
