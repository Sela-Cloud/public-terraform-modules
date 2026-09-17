variable "project_id" {
  description = "The GCP Project ID in which the Managed Kafka clusters are created."
  type        = string
}

variable "managed_kafka" {
  description = "The details of the Managed Kafka clusters to create, keyed by cluster id."
  type = map(object({
    cluster_id      = string
    region          = string
    subnet_name     = string
    vcpu_count      = number
    memory_size_gib = number

    # Set only under Shared VPC, when the subnet lives in a host project rather
    # than the project above.
    host_project_id  = optional(string, "")
    rebalance_config = optional(string, "AUTO_REBALANCE_ON_SCALE_UP")
    labels           = optional(map(string), {})

    kafka_topics = optional(map(object({
      topic_id           = string
      partition_count    = number
      replication_factor = number
      configs            = optional(map(string), {})
    })), {})
  }))
  default = {}
}
