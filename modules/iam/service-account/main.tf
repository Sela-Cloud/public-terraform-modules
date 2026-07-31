
resource "google_service_account" "service_account" {
  count        = var.existing_service_account_email == "" && var.service_account_name != "" ? 1 : 0
  account_id   = var.service_account_name
  display_name = var.service_account_name
  project      = var.project_id
}

resource "google_service_account_iam_member" "iam_binding" {
  for_each           = var.iam_members
  service_account_id = var.existing_service_account_email == "" ? google_service_account.service_account[0].name : var.existing_service_account_email
  role               = each.value.role
  member             = each.value.member
}
