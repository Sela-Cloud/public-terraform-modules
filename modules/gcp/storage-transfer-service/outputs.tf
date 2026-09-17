output "job_names" {
  description = "Map of job_name to the created transfer job's resource name (transferJobs/...)."
  value       = { for k, v in google_storage_transfer_job.this : k => v.name }
}

output "service_account_email" {
  description = "Email of this project's Storage Transfer Service agent."
  value       = data.google_storage_transfer_project_service_account.this.email
}
