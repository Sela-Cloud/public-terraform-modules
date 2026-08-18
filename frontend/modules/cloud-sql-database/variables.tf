variable "project_id" {
  description = "GCP Project ID that owns the parent Cloud SQL instance."
  type        = string
}

variable "cloud_sql_database" {
  description = "Cloud SQL databases configured through the Sela Deployer catalog. One map entry is exactly one database on an existing Cloud SQL instance, so a database can be removed without touching its instance or its sibling databases."
  type = map(object({
    database_key    = string
    instance_name   = string
    name            = string
    charset         = optional(string)
    collation       = optional(string)
    deletion_policy = optional(string, "ABANDON")
  }))
  default = {}

  validation {
    condition = alltrue([
      for database in values(var.cloud_sql_database) :
      trimspace(database.instance_name) != ""
    ])
    error_message = "Every Cloud SQL database must name the Cloud SQL instance that hosts it."
  }

  validation {
    condition = alltrue([
      for database in values(var.cloud_sql_database) :
      contains(["ABANDON", "DELETE"], database.deletion_policy)
    ])
    error_message = "Cloud SQL database deletion policy must be ABANDON or DELETE."
  }
}
