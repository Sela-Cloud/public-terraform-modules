################################################################################
# Cluster IAM Role
################################################################################

data "aws_iam_policy_document" "cluster_assume_role" {
  count = var.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  count              = var.create_iam_role ? 1 : 0
  name               = "${var.name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  count      = var.create_iam_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "vpc_controller" {
  count      = var.create_iam_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

################################################################################
# Automatic VPC & Subnet Discovery (Fallback)
################################################################################

data "aws_vpc" "default" {
  count   = (length(var.subnet_ids) == 0 && length(var.control_plane_subnet_ids) == 0 && var.vpc_id == null) || (var.create_cluster_security_group && var.vpc_id == null) ? 1 : 0
  default = true
}

locals {
  effective_vpc_id = coalesce(var.vpc_id, try(data.aws_vpc.default[0].id, null))
}

data "aws_subnets" "discovered" {
  count = length(var.subnet_ids) == 0 && length(var.control_plane_subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.effective_vpc_id]
  }
}

locals {
  cluster_subnet_ids = length(var.control_plane_subnet_ids) > 0 ? var.control_plane_subnet_ids : (
    length(var.subnet_ids) > 0 ? var.subnet_ids : try(data.aws_subnets.discovered[0].ids, [])
  )
}

################################################################################
# Dedicated Security Group for Cluster
################################################################################

resource "aws_security_group" "cluster" {
  count       = var.create_cluster_security_group && local.effective_vpc_id != null ? 1 : 0
  name        = "${var.name}-cluster-sg"
  description = "EKS cluster control plane security group"
  vpc_id      = local.effective_vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-cluster-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cluster_ingress" {
  count = var.create_cluster_security_group && local.effective_vpc_id != null ? 1 : 0

  security_group_id = aws_security_group.cluster[0].id
  description       = "Allow inbound traffic from control plane"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "cluster_egress" {
  count = var.create_cluster_security_group && local.effective_vpc_id != null ? 1 : 0

  security_group_id = aws_security_group.cluster[0].id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.create_iam_role ? aws_iam_role.cluster[0].arn : var.iam_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = local.cluster_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = compact(concat(var.security_group_ids, try([aws_security_group.cluster[0].id], [])))
  }

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  dynamic "kubernetes_network_config" {
    for_each = var.kubernetes_network_config != null ? [var.kubernetes_network_config] : []
    content {
      service_ipv4_cidr = try(kubernetes_network_config.value.service_ipv4_cidr, null)
      ip_family         = try(kubernetes_network_config.value.ip_family, "ipv4")
    }
  }

  dynamic "upgrade_policy" {
    for_each = var.upgrade_policy_support_type != null ? [1] : []
    content {
      support_type = var.upgrade_policy_support_type
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.enable_zonal_shift ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.vpc_controller
  ]
}

################################################################################
# OIDC Provider (IRSA - IAM Roles for Service Accounts)
################################################################################

data "tls_certificate" "this" {
  count = var.create_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-irsa"
    }
  )
}

################################################################################
# Node Group IAM Role
################################################################################

data "aws_iam_policy_document" "node_assume_role" {
  count = var.create_node_iam_role && length(var.node_groups) > 0 ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  count              = var.create_node_iam_role && length(var.node_groups) > 0 ? 1 : 0
  name               = "${var.name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  count      = var.create_node_iam_role && length(var.node_groups) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  count      = var.create_node_iam_role && length(var.node_groups) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_registry_ro" {
  count      = var.create_node_iam_role && length(var.node_groups) > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node[0].name
}

################################################################################
# Managed Node Groups
################################################################################

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = coalesce(each.value.node_group_name, "${var.name}-${each.key}")
  node_role_arn   = coalesce(try(each.value.node_role_arn, null), try(aws_iam_role.node[0].arn, null), var.node_iam_role_arn)
  subnet_ids      = coalesce(try(each.value.subnet_ids, null), local.cluster_subnet_ids)

  instance_types       = try(each.value.instance_types, ["t3.medium"])
  capacity_type        = try(each.value.capacity_type, "ON_DEMAND")
  disk_size            = try(each.value.disk_size, 20)
  ami_type             = try(each.value.ami_type, "AL2023_x86_64_STANDARD")
  force_update_version = try(each.value.force_update_version, false)

  scaling_config {
    desired_size = try(each.value.scaling_config.desired_size, 2)
    max_size     = try(each.value.scaling_config.max_size, 5)
    min_size     = try(each.value.scaling_config.min_size, 1)
  }

  dynamic "update_config" {
    for_each = try(each.value.update_config, null) != null ? [each.value.update_config] : []
    content {
      max_unavailable            = try(update_config.value.max_unavailable, null)
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
    }
  }

  labels = try(each.value.labels, {})

  dynamic "taint" {
    for_each = try(each.value.taints, [])
    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  dynamic "launch_template" {
    for_each = try(each.value.launch_template, null) != null ? [each.value.launch_template] : []
    content {
      id      = try(launch_template.value.id, null)
      name    = try(launch_template.value.name, null)
      version = try(launch_template.value.version, "$Latest")
    }
  }

  dynamic "remote_access" {
    for_each = try(each.value.remote_access, null) != null ? [each.value.remote_access] : []
    content {
      ec2_ssh_key               = try(remote_access.value.ec2_ssh_key, null)
      source_security_group_ids = try(remote_access.value.source_security_group_ids, null)
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = coalesce(each.value.node_group_name, "${var.name}-${each.key}")
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_ro
  ]
}

################################################################################
# EKS Addons
################################################################################

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value.addon_name
  addon_version               = try(each.value.addon_version, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)
  configuration_values        = try(each.value.configuration_values, null)

  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )

  depends_on = [
    aws_eks_node_group.this
  ]
}

################################################################################
# EKS Access Entries & Policy Associations
################################################################################

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, "STANDARD")
  user_name         = try(each.value.user_name, null)
  kubernetes_groups = try(each.value.kubernetes_groups, [])

  tags = var.tags
}

locals {
  access_policy_associations = flatten([
    for entry_key, entry in var.access_entries : [
      for assoc_key, assoc in try(entry.policy_associations, {}) : {
        key           = "${entry_key}.${assoc_key}"
        principal_arn = entry.principal_arn
        policy_arn    = assoc.policy_arn
        access_scope  = assoc.access_scope
      }
    ]
  ])
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for assoc in local.access_policy_associations : assoc.key => assoc }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = try(each.value.access_scope.namespaces, null)
  }

  depends_on = [
    aws_eks_access_entry.this
  ]
}

################################################################################
# EKS Pod Identity Associations
################################################################################

resource "aws_eks_pod_identity_association" "this" {
  for_each = var.pod_identity_associations

  cluster_name    = aws_eks_cluster.this.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn

  tags = var.tags
}

