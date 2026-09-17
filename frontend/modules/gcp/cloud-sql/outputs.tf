output "instances" {
  value = {
    for key, instance in module.cloud_sql_instance : key => {
      name            = instance.name
      connection_name = instance.connection_name
      private_ip      = instance.private_ip_address
      public_ip       = instance.public_ip_address
    }
  }
}

output "databases" { value = { for key, database in module.cloud_sql_database : key => database.name } }
output "iam_users" { value = { for key, user in module.cloud_sql_user : key => user.name } }
