variable "project_id" { type = string }
variable "repository_id" { type = string }
variable "location" { type = string }
variable "format" { type = string }
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
