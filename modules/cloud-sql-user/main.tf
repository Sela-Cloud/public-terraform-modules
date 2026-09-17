resource "google_sql_user" "this" {
  project         = var.project_id
  instance        = var.instance_name
  name            = var.name
  type            = var.type
  deletion_policy = var.deletion_policy
}

resource "google_project_iam_member" "instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = var.iam_member
}
