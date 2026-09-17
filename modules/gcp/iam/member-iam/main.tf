resource "google_project_iam_member" "project_iam_member" {
  for_each = toset(var.project_roles)
  project  = var.project
  role     = each.key
  member = coalesce(
    var.principal_set_address != null ? "principal://${var.principal_set_address}" : null,
    var.service_account_address != null ? "serviceAccount:${var.service_account_address}" : null,
    var.user_email_address != null ? "user:${var.user_email_address}" : null,
    ""
  )
}
