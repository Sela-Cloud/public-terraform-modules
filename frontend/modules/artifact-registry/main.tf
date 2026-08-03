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
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/artifact-registry?ref=v0.5.1"
  for_each = local.repositories

  project_id                        = var.project_id
  repository_id                     = each.value.repository_id
  location                          = each.value.location
  format                            = each.value.format
  description                       = try(trimspace(each.value.description), "") != "" ? each.value.description : null
  labels                            = each.value.labels
  docker_immutable_tags             = each.value.docker_immutable_tags
  maven_version_policy              = try(trimspace(each.value.maven_version_policy), "") != "" ? each.value.maven_version_policy : null
  maven_allow_snapshot_overwrites   = each.value.maven_allow_snapshot_overwrites
  cleanup_policy_dry_run            = each.value.cleanup_policy_dry_run
  vulnerability_scanning_enablement = try(trimspace(each.value.vulnerability_scanning_enablement), "") != "" ? each.value.vulnerability_scanning_enablement : null
  cleanup_policies                  = each.value.cleanup_policies
  iam_bindings                      = each.value.iam_bindings
}
