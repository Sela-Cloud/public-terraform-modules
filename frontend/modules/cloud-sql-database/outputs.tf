output "databases" {
  description = "Cloud SQL database names keyed by the configured resource key."
  value       = { for key, database in module.cloud_sql_database : key => database.name }
}
