variable "project_id" {
  description = "Project ID in which to create the GCP Managed Kafka cluster."
  type        = string
  nullable    = false
}

variable "region" {
  description = "The GCP region in which to create the Kafka cluster."
  type        = string
  nullable    = false
}

variable "cluster_id" {
  description = "The name of the Managed Kafka cluster."
  type        = string
  nullable    = false
}

variable "subnet_id" {
  description = "Full path of the subnet the cluster is provisioned into, projects/<project>/regions/<region>/subnetworks/<name>."
  type        = string
  nullable    = false
}

variable "vcpu_count" {
  description = "The vCPU count for the provisioned Kafka cluster."
  type        = number
  nullable    = false
}

variable "memory_size_gib" {
  description = "The memory size (in GiB) for the provisioned Kafka cluster."
  type        = number
  nullable    = false
}

variable "rebalance_config" {
  description = "The rebalance behaviour for the cluster."
  type        = string
  nullable    = false
  default     = "AUTO_REBALANCE_ON_SCALE_UP"
}

variable "labels" {
  description = "Labels to apply to the cluster, provided as a map."
  type        = map(string)
  default     = {}
}

variable "kafka_topics" {
  description = "Topics to create on the cluster, keyed by a stable identifier."
  type = map(object({
    topic_id           = string
    partition_count    = number
    replication_factor = number
    configs            = optional(map(string), {})
  }))
  default = {}
}

variable "configure_kafka_connectors" {
  description = "Create a Kafka Connect cluster and a Pub/Sub source connector alongside the cluster. See kafka_connector.tf -- the connector configuration is a worked example, not a parameterised input."
  type        = bool
  default     = false
}
