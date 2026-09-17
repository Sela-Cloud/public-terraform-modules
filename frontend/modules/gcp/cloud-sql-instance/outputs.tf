output "instances" {
  description = "Cloud SQL instance identity and connectivity keyed by the configured resource key."
  value = {
    for key, instance in module.cloud_sql_instance : key => {
      name            = instance.name
      connection_name = instance.connection_name
      private_ip      = instance.private_ip_address
      public_ip       = instance.public_ip_address
    }
  }
}
