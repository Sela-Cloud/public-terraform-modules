module "cloud_sql_database" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-sql-database?ref=v0.6.11"
  for_each = var.cloud_sql_database

  project_id      = var.project_id
  instance_name   = each.value.instance_name
  name            = each.value.name
  charset         = try(trimspace(each.value.charset), "") != "" ? each.value.charset : null
  collation       = try(trimspace(each.value.collation), "") != "" ? each.value.collation : null
  deletion_policy = each.value.deletion_policy
}
