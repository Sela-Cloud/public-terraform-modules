# ---------------------------------------------------------------------------
# Optional Kafka Connect cluster and a Pub/Sub source connector.
#
# Off by default. The connector's `configs` below are a worked example rather
# than module inputs: the topic and subscription are placeholders, and there is
# one connector with a fixed id, so this creates the same connector for every
# cluster it is enabled on. Parameterise it before using it for real.
# ---------------------------------------------------------------------------

resource "google_managed_kafka_connect_cluster" "mkc_cluster" {
  provider           = google-beta
  count              = var.configure_kafka_connectors ? 1 : 0
  project            = var.project_id
  connect_cluster_id = "${var.cluster_id}-connect"
  kafka_cluster      = google_managed_kafka_cluster.kafka_cluster.id
  location           = var.region

  capacity_config {
    vcpu_count   = var.vcpu_count
    memory_bytes = var.memory_size_gib * 1024 * 1024 * 1024
  }

  gcp_config {
    access_config {
      network_configs {
        # The Connect cluster sits on the same subnet as the Kafka cluster, and
        # resolves it through the cluster's regional DNS domain.
        primary_subnet   = var.subnet_id
        dns_domain_names = ["${google_managed_kafka_cluster.kafka_cluster.cluster_id}.${var.region}.managedkafka.${var.project_id}.cloud.goog"]
      }
    }
  }
}

resource "google_managed_kafka_connector" "managed_kafka_connectors" {
  provider        = google-beta
  count           = var.configure_kafka_connectors ? 1 : 0
  project         = var.project_id
  connector_id    = "${var.cluster_id}-pubsub-source"
  connect_cluster = google_managed_kafka_connect_cluster.mkc_cluster[0].connect_cluster_id
  location        = var.region

  configs = {
    "connector.class"  = "com.google.pubsub.kafka.source.CloudPubSubSourceConnector"
    "name"             = "${var.cluster_id}-pubsub-source"
    "tasks.max"        = "1"
    "kafka.topic"      = "GMK_TOPIC_ID"
    "cps.subscription" = "CPS_SUBSCRIPTION_ID"
    "cps.project"      = var.project_id
    "value.converter"  = "org.apache.kafka.connect.converters.ByteArrayConverter"
    "key.converter"    = "org.apache.kafka.connect.storage.StringConverter"
  }
}
