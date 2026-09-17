output "email" {
  value = var.existing_service_account_email != "" ? var.existing_service_account_email : try(google_service_account.service_account[0].email, null)
}

output "name" {
  value = try(google_service_account.service_account[0].name, null)
}
