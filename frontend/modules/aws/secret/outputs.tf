output "secrets_summary" {
  description = "A mapping of secret keys to their generated ARNs and names."
  value = {
    for key, value in module.secrets : key => {
      id               = value.id
      arn              = value.arn
      name             = value.name
      rotation_enabled = value.rotation_enabled
    }
  }
}

output "secrets_replica_attributes" {
  description = "A mapping of secret keys to their multi-region replica deployment attributes."
  value = {
    for key, value in module.secrets : key => value.replica_attributes
    if length(value.replica_attributes) > 0
  }
}
