/******************************************
  AWS EKS Root Module
 *****************************************/

module "eks" {
  source   = "../../../../modules/aws/eks"
  for_each = var.eks

  name                                        = coalesce(each.value.name, each.key)
  kubernetes_version                          = each.value.kubernetes_version
  vpc_id                                      = each.value.vpc_id
  subnet_ids                                  = each.value.subnet_ids
  control_plane_subnet_ids                    = each.value.control_plane_subnet_ids
  endpoint_private_access                     = each.value.endpoint_private_access
  endpoint_public_access                      = each.value.endpoint_public_access
  public_access_cidrs                         = each.value.public_access_cidrs
  security_group_ids                          = each.value.security_group_ids
  create_cluster_security_group               = each.value.create_cluster_security_group
  create_iam_role                             = each.value.create_iam_role
  iam_role_arn                                = each.value.iam_role_arn
  enabled_cluster_log_types                   = each.value.enabled_cluster_log_types
  authentication_mode                         = each.value.authentication_mode
  bootstrap_cluster_creator_admin_permissions = each.value.bootstrap_cluster_creator_admin_permissions
  kms_key_arn                                 = each.value.kms_key_arn
  create_oidc_provider                        = each.value.create_oidc_provider
  create_node_iam_role                        = each.value.create_node_iam_role
  node_iam_role_arn                           = each.value.node_iam_role_arn
  kubernetes_network_config                   = each.value.kubernetes_network_config
  upgrade_policy_support_type                 = each.value.upgrade_policy_support_type
  enable_zonal_shift                          = each.value.enable_zonal_shift
  bootstrap_self_managed_addons               = each.value.bootstrap_self_managed_addons
  node_groups                                 = each.value.node_groups
  cluster_addons                              = each.value.cluster_addons
  pod_identity_associations                   = each.value.pod_identity_associations
  tags                                        = each.value.tags
}

