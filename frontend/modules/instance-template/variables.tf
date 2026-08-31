variable "project_id" {
  description = "The GCP Project ID in which the instance template is created."
  type        = string
}

variable "instance_template" {
  description = "The details of the Instance Templates to create, keyed by name prefix."
  type = map(object({
    name_prefix          = string
    description          = optional(string, "")
    instance_description = optional(string, "")
    region               = string
    machine_type         = optional(string, "e2-medium")
    min_cpu_platform     = optional(string, "")
    labels               = optional(map(string), {})

    # Boot disk
    source_image           = optional(string, "")
    source_image_family    = optional(string, "rocky-linux-9-optimized-gcp")
    source_image_project   = optional(string, "rocky-linux-cloud")
    disk_size_gb           = optional(number, 100)
    disk_type              = optional(string, "pd-standard")
    auto_delete            = optional(bool, true)
    disk_labels            = optional(map(string), {})
    disk_encryption_key    = optional(string, "")
    disk_resource_policies = optional(list(string), [])

    # Additional disks
    additional_disks = optional(list(object({
      auto_delete     = optional(bool, true)
      boot            = optional(bool, false)
      device_name     = optional(string)
      disk_name       = optional(string)
      disk_size_gb    = optional(number)
      disk_type       = optional(string)
      disk_labels     = optional(map(string), {})
      interface       = optional(string)
      mode            = optional(string)
      source          = optional(string)
      source_image    = optional(string)
      source_snapshot = optional(string)
    })), [])

    # Networking
    network                     = optional(string, "")
    subnetwork                  = optional(string, "")
    subnetwork_project          = optional(string, "")
    network_ip                  = optional(string, "")
    nic_type                    = optional(string, null)
    stack_type                  = optional(string, null)
    network_tags                = optional(list(string), [])
    can_ip_forward              = optional(bool, false)
    total_egress_bandwidth_tier = optional(string, "DEFAULT")
    access_config = optional(list(object({
      nat_ip       = optional(string, "")
      network_tier = optional(string, "PREMIUM")
    })), [])
    ipv6_access_config = optional(list(object({
      network_tier = optional(string, "PREMIUM")
    })), [])
    alias_ip_range = optional(object({
      ip_cidr_range         = string
      subnetwork_range_name = optional(string, "")
    }), null)

    # Identity
    service_account = object({
      email  = string
      scopes = optional(set(string), ["cloud-platform"])
    })

    # Security
    enable_shielded_vm = optional(bool, false)
    shielded_instance_config = optional(object({
      enable_secure_boot          = optional(bool, true)
      enable_vtpm                 = optional(bool, true)
      enable_integrity_monitoring = optional(bool, true)
    }), null)
    enable_confidential_vm     = optional(bool, false)
    confidential_instance_type = optional(string, null)

    # Scheduling
    preemptible                      = optional(bool, false)
    spot                             = optional(bool, false)
    spot_instance_termination_action = optional(string, "STOP")
    automatic_restart                = optional(bool, true)
    on_host_maintenance              = optional(string, "MIGRATE")
    maintenance_interval             = optional(string, null)

    # Advanced
    metadata                     = optional(map(string), {})
    startup_script               = optional(string, "")
    enable_nested_virtualization = optional(bool, false)
    threads_per_core             = optional(number, null)
    resource_policies            = optional(list(string), [])
    gpu = optional(object({
      type  = string
      count = number
    }), null)
  }))
  default = {}
}
