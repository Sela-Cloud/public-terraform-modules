locals {
  repositories = {
    for key, repository in var.artifact_registry : key => merge(repository, {
      cleanup_policies = {
        for policy in repository.cleanup_policies : policy.id => policy
      }
      iam_bindings = {
        for binding in repository.iam_bindings : "${binding.role}|${binding.member}" => binding
      }
    })
  }
}

module "artifact_registry" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/artifact-registry?ref=v0.5.4"
  for_each = local.repositories

  project_id                        = var.project_id
  repository_id                     = each.value.repository_id
  location                          = each.value.location
  format                            = each.value.format
  mode                              = each.value.mode
  kms_key_name                      = try(trimspace(each.value.kms_key_name), "") != "" ? each.value.kms_key_name : null
  description                       = try(trimspace(each.value.description), "") != "" ? each.value.description : null
  labels                            = each.value.labels
  docker_immutable_tags             = each.value.docker_immutable_tags
  maven_version_policy              = try(trimspace(each.value.maven_version_policy), "") != "" ? each.value.maven_version_policy : null
  maven_allow_snapshot_overwrites   = each.value.maven_allow_snapshot_overwrites
  remote_upstream                   = try(trimspace(each.value.remote_upstream), "") != "" ? each.value.remote_upstream : null
  remote_custom_uri                 = try(trimspace(each.value.remote_custom_uri), "") != "" ? each.value.remote_custom_uri : null
  remote_apt_repository_base        = try(trimspace(each.value.remote_apt_repository_base), "") != "" ? each.value.remote_apt_repository_base : null
  remote_apt_repository_path        = try(trimspace(each.value.remote_apt_repository_path), "") != "" ? each.value.remote_apt_repository_path : null
  remote_yum_repository_base        = try(trimspace(each.value.remote_yum_repository_base), "") != "" ? each.value.remote_yum_repository_base : null
  remote_yum_repository_path        = try(trimspace(each.value.remote_yum_repository_path), "") != "" ? each.value.remote_yum_repository_path : null
  remote_credentials_username       = try(trimspace(each.value.remote_credentials_username), "") != "" ? each.value.remote_credentials_username : null
  remote_password_secret_version    = try(trimspace(each.value.remote_password_secret_version), "") != "" ? each.value.remote_password_secret_version : null
  disable_upstream_validation       = each.value.disable_upstream_validation
  virtual_upstream_policies         = each.value.virtual_upstream_policies
  cleanup_policy_dry_run            = each.value.cleanup_policy_dry_run
  vulnerability_scanning_enablement = try(trimspace(each.value.vulnerability_scanning_enablement), "") != "" ? each.value.vulnerability_scanning_enablement : null
  cleanup_policies                  = each.value.cleanup_policies
  iam_bindings                      = each.value.iam_bindings
}
