variable "compute_instance" {
  description = "The details of the Compute Instance."
  type = map(object({
    machine_name            = string,
    region                  = string,
    enable_external_ip      = bool,
    generate_internal_ip    = bool,
    internal_ip_address     = list(string),
    vm_description          = optional(string, ""),
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
    enable_data_disk = optional(bool, false),
    data_disk = optional(list(object({
      disk_size_gb = number,
      disk_type    = string
    })), null),
    disk_labels          = optional(map(string), {}),
    snapshot_policy_name = optional(string, null),
    enable_shielded_vm   = optional(bool, true),
    shielded_instance_config = optional(object({
      enable_secure_boot          = bool,
      enable_vtpm                 = bool,
      enable_integrity_monitoring = bool
    }), null)
  }))
  default = {}
}

variable "project" {
  description = "The GCP Project ID."
  type        = string
}
