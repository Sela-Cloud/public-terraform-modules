output "job_names" {
  description = "Transfer job resource names, keyed by deployment then job_name."
  value       = { for key, sts in module.storage_transfer_service : key => sts.job_names }
}

output "service_account_emails" {
  description = "Storage Transfer Service agent email for each deployment's project."
  value       = { for key, sts in module.storage_transfer_service : key => sts.service_account_email }
}
