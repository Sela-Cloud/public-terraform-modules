
resource "google_service_account" "service_account" {
  count        = var.existing_service_account_email == "" && var.service_account_name != "" ? 1 : 0
  account_id   = var.service_account_name
  display_name = var.service_account_name
  project      = var.project_id
}

locals {
  # Callers supply an email; the provider wants a fully-qualified resource name and validates the
  # shape before it makes any API call. The two branches of the old ternary returned different
  # shapes -- `.name` on a created service account is already `projects/<p>/serviceAccounts/<email>`,
  # while the variable holds a bare email -- so binding to a pre-created service account always
  # failed with an unreadable regexp error. Qualifying it here keeps the module's input an email.
  #
  # `projects/-` resolves the account by email, so a pre-created service account that lives in a
  # different project from var.project_id still works.
  #
  # An already-qualified value is passed through rather than prefixed again, so a caller who reads
  # the provider docs and supplies a full path is not punished for it.
  existing_service_account_id = (
    var.existing_service_account_email == "" ? "" :
    startswith(var.existing_service_account_email, "projects/") ?
    var.existing_service_account_email :
    "projects/-/serviceAccounts/${var.existing_service_account_email}"
  )
}

resource "google_service_account_iam_member" "iam_binding" {
  for_each           = var.iam_members
  service_account_id = var.existing_service_account_email == "" ? google_service_account.service_account[0].name : local.existing_service_account_id
  role               = each.value.role
  member             = each.value.member
}
