resource "google_sql_database" "this" {
  project         = var.project_id
  instance        = var.instance_name
  name            = var.name
  charset         = var.charset
  collation       = var.collation
  deletion_policy = var.deletion_policy
}
