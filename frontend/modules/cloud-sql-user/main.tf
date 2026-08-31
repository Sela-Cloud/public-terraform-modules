module "cloud_sql_user" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-sql-user?ref=v0.6.5"
  for_each = var.cloud_sql_user

  project_id      = var.project_id
  instance_name   = each.value.instance_name
  name            = each.value.name
  type            = each.value.type
  iam_member      = each.value.iam_member
  deletion_policy = each.value.deletion_policy
}
