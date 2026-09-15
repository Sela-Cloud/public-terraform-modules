output "kafka_cluster_names" {
  description = "Fully qualified name of each Managed Kafka cluster, keyed by resource name."
  value       = { for key, cluster in module.managed_kafka : key => cluster.cluster_name }
}

output "kafka_cluster_ids" {
  description = "Short cluster id of each Managed Kafka cluster, keyed by resource name. Clients and topics refer to this."
  value       = { for key, cluster in module.managed_kafka : key => cluster.cluster_id }
}

output "kafka_topic_ids" {
  description = "Topic ids created on each cluster, keyed by resource name."
  value       = { for key, cluster in module.managed_kafka : key => cluster.topic_ids }
}
