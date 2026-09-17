resource "google_managed_kafka_cluster" "kafka_cluster" {
  project    = var.project_id
  cluster_id = var.cluster_id
  location   = var.region
  labels     = var.labels

  capacity_config {
    vcpu_count   = var.vcpu_count
    memory_bytes = var.memory_size_gib * 1024 * 1024 * 1024
  }

  gcp_config {
    access_config {
      network_configs {
        subnet = var.subnet_id
      }
    }
  }

  rebalance_config {
    mode = var.rebalance_config
  }
}

resource "google_managed_kafka_topic" "kafka_topic" {
  for_each = var.kafka_topics

  project            = var.project_id
  topic_id           = each.value.topic_id
  cluster            = google_managed_kafka_cluster.kafka_cluster.cluster_id
  location           = var.region
  partition_count    = each.value.partition_count
  replication_factor = each.value.replication_factor
  configs            = each.value.configs
}
