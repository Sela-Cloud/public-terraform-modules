variable "project_id" {
  type = string
}

variable "artifact_registry" {
  type = map(object({
    repository_id                     = string
    location                          = string
    format                            = string
    description                       = optional(string)
    labels                            = optional(map(string), {})
    docker_immutable_tags             = optional(bool, false)
    maven_version_policy              = optional(string)
    maven_allow_snapshot_overwrites   = optional(bool, false)
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
      contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "GENERIC"], repository.format)
    ])
    error_message = "Artifact Registry Phase 1 supports DOCKER, MAVEN, NPM, PYTHON, and GENERIC repositories only."
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
      repository.vulnerability_scanning_enablement == null || contains(["INHERITED", "DISABLED"], repository.vulnerability_scanning_enablement)
    ])
    error_message = "Vulnerability scanning must be INHERITED or DISABLED when configured."
  }

  validation {
    condition = alltrue(flatten([
      for repository in values(var.artifact_registry) : [
        for policy in repository.cleanup_policies :
        contains(["DELETE", "KEEP"], policy.action) && contains(["ANY", "TAGGED", "UNTAGGED"], policy.tag_state)
      ]
    ]))
    error_message = "Cleanup policies must use DELETE or KEEP with an ANY, TAGGED, or UNTAGGED tag state."
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
