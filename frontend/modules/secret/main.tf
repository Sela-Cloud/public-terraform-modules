module "secret" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/secret?ref=v0.7.1"
  for_each = var.secret

  project_id          = var.project_id
  secret_id           = each.value.secret_id
  labels              = each.value.labels
  annotations         = each.value.annotations
  deletion_protection = each.value.deletion_protection
  custom_replication  = each.value.custom_replication
  kms_key_name        = each.value.kms_key_name
  replica_locations   = each.value.replica_locations
  expire_time         = each.value.expire_time
  version_destroy_ttl = each.value.version_destroy_ttl
  set_rotation        = each.value.set_rotation
  rotation_period     = each.value.rotation_period
  next_rotation_time  = each.value.next_rotation_time
  topics              = each.value.topics
}
