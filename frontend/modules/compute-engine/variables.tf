variable "compute_instance" {
  description = "The details of the Compute Instance."
  type = map(object({
    machine_name            = string,
    project_id              = string,
    region                  = string,
    enable_external_ip      = bool,
    generate_internal_ip    = bool,
    internal_ip_address     = list(string),
    vm_description          = string,
    instance_count          = number,
    network                 = string,
    subnetwork              = string,
    machine_zone            = list(string),
    vm_deletion_protect     = bool,
    instance_image_selflink = string,
    machine_type            = string,
    instance_labels         = map(string),
    network_tags            = list(string),
    metadata                = map(string),
    metadata_startup_script = optional(string, null),
    can_ip_forward          = optional(bool, null),
    service_account = object({
      email  = string,
      scopes = set(string)
    })
    boot_disk0_info = object({
      disk_size_gb = number,
      disk_type    = string
    })
  }))
  default = {
    compute_insatnce = {
      machine_name            = ""
      project_id              = ""
      region                  = "asia-south2"
      enable_external_ip      = false
      generate_internal_ip    = true
      internal_ip_address     = [""]
      machine_zone            = []
      vm_description          = ""
      instance_count          = 1
      network                 = ""
      subnetwork              = ""
      vm_deletion_protect     = true
      instance_image_selflink = ""
      machine_type            = ""
      instance_labels         = {}
      disk_labels             = {}
      network_tags            = []
      metadata                = {}
      metadata_startup_script = null
      service_account         = null
      snapshot_policy_name    = ""
      boot_disk0_info = {
        disk_size_gb = 10,
        disk_type    = "pd-balanced"
      }
      enable_data_disk = false
    }
  }
}
