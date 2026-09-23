/******************************************
  Details of the Managed Kafka cluster
 *****************************************/

module "managed_kafka" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/gcp/managed-kafka?ref=v0.7.8"
  for_each = var.managed_kafka

  project_id = var.project_id
  cluster_id = each.value.cluster_id
  region     = each.value.region

  # The cluster wants the subnet's full path. Building it beats a data source
  # lookup: no extra read permission on the host project, and the string matches
  # what the API stores, so it cannot drift.
  subnet_id = format(
    "projects/%s/regions/%s/subnetworks/%s",
    trimspace(each.value.host_project_id) != "" ? each.value.host_project_id : var.project_id,
    each.value.region,
    each.value.subnet_name,
  )

  vcpu_count       = each.value.vcpu_count
  memory_size_gib  = each.value.memory_size_gib
  rebalance_config = each.value.rebalance_config
  labels           = each.value.labels
  kafka_topics     = each.value.kafka_topics
}
