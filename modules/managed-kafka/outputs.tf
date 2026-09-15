output "cluster_name" {
  description = "The fully qualified name of the GCP Managed Kafka cluster."
  value       = google_managed_kafka_cluster.kafka_cluster.name
}

output "cluster_id" {
  description = "The short cluster id, as referenced by clients and topics."
  value       = google_managed_kafka_cluster.kafka_cluster.cluster_id
}

output "id" {
  description = "The Terraform resource id of the cluster."
  value       = google_managed_kafka_cluster.kafka_cluster.id
}

output "topic_ids" {
  description = "The topic ids created on the cluster, keyed by the configured topic key."
  value       = { for key, topic in google_managed_kafka_topic.kafka_topic : key => topic.topic_id }
}
