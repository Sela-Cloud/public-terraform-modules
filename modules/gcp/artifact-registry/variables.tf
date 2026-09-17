variable "project_id" { type = string }
variable "repository_id" { type = string }
variable "location" { type = string }
variable "format" { type = string }
variable "mode" {
  type    = string
  default = "STANDARD_REPOSITORY"
}
variable "kms_key_name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "docker_immutable_tags" {
  type    = bool
  default = false
}
variable "maven_version_policy" {
  type    = string
  default = null
}
variable "maven_allow_snapshot_overwrites" {
  type    = bool
  default = false
}
variable "remote_upstream" {
  type    = string
  default = null
}
variable "remote_custom_uri" {
  type    = string
  default = null
}
variable "remote_apt_repository_base" {
  type    = string
  default = null
}
variable "remote_apt_repository_path" {
  type    = string
  default = null
}
variable "remote_yum_repository_base" {
  type    = string
  default = null
}
variable "remote_yum_repository_path" {
  type    = string
  default = null
}
variable "remote_credentials_username" {
  type    = string
  default = null
}
variable "remote_password_secret_version" {
  type    = string
  default = null
}
variable "disable_upstream_validation" {
  type    = bool
  default = false
}
variable "virtual_upstream_policies" {
  type = list(object({
    id         = string
    repository = string
    priority   = number
  }))
  default = []
}
variable "cleanup_policy_dry_run" {
  type    = bool
  default = true
}
variable "vulnerability_scanning_enablement" {
  type    = string
  default = null
}
variable "cleanup_policies" {
  type = map(object({
    id                    = string
    action                = string
    tag_state             = optional(string, "ANY")
    tag_prefixes          = optional(list(string), [])
    package_name_prefixes = optional(list(string), [])
    version_name_prefixes = optional(list(string), [])
    older_than            = optional(string)
    newer_than            = optional(string)
    keep_count            = optional(number)
  }))
  default = {}
}
variable "iam_bindings" {
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}
