/******************************************
  Details of the Instance Template
 *****************************************/

module "instance_template" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/instance_template?ref=v0.7.0"
  for_each = var.instance_template

  project_id           = var.project_id
  name_prefix          = each.value.name_prefix
  description          = each.value.description
  instance_description = each.value.instance_description
  region               = each.value.region
  machine_type         = each.value.machine_type
  labels               = each.value.labels

  # The remote module writes min_cpu_platform straight onto the resource, and an empty
  # string is not a valid CPU platform -- an untouched text field must arrive as null.
  min_cpu_platform = trimspace(each.value.min_cpu_platform) != "" ? each.value.min_cpu_platform : null

  # Boot disk. source_image is deliberately left as "" when unset: the remote module
  # falls back to source_image_family only while this is empty.
  source_image           = each.value.source_image
  source_image_family    = each.value.source_image_family
  source_image_project   = each.value.source_image_project
  disk_size_gb           = each.value.disk_size_gb
  disk_type              = each.value.disk_type
  auto_delete            = each.value.auto_delete
  disk_labels            = each.value.disk_labels
  disk_resource_policies = each.value.disk_resource_policies

  # The remote module gates the disk_encryption_key block on `!= null`, so a blank
  # field would otherwise emit the block with an empty KMS key.
  disk_encryption_key = trimspace(each.value.disk_encryption_key) != "" ? each.value.disk_encryption_key : null

  additional_disks = each.value.additional_disks

  # Networking
  network                     = each.value.network
  subnetwork                  = each.value.subnetwork
  subnetwork_project          = each.value.subnetwork_project
  network_ip                  = each.value.network_ip
  nic_type                    = each.value.nic_type
  stack_type                  = each.value.stack_type
  network_tags                = each.value.network_tags
  can_ip_forward              = each.value.can_ip_forward
  total_egress_bandwidth_tier = each.value.total_egress_bandwidth_tier

  # A blank nat_ip means "let Compute Engine allocate an ephemeral address"; the
  # provider wants that as null rather than as an empty string.
  access_config = [
    for ac in each.value.access_config : {
      nat_ip       = trimspace(ac.nat_ip) != "" ? ac.nat_ip : null
      network_tier = ac.network_tier
    }
  ]
  ipv6_access_config = each.value.ipv6_access_config

  # An unset secondary range name means "use the subnet's primary range".
  alias_ip_range = each.value.alias_ip_range == null ? null : {
    ip_cidr_range         = each.value.alias_ip_range.ip_cidr_range
    subnetwork_range_name = trimspace(each.value.alias_ip_range.subnetwork_range_name) != "" ? each.value.alias_ip_range.subnetwork_range_name : null
  }

  service_account = each.value.service_account

  # The remote module lookup()s into shielded_instance_config whenever
  # enable_shielded_vm is true, so it must never be null there.
  enable_shielded_vm = each.value.enable_shielded_vm
  shielded_instance_config = coalesce(each.value.shielded_instance_config, {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  })

  enable_confidential_vm     = each.value.enable_confidential_vm
  confidential_instance_type = each.value.confidential_instance_type

  # Scheduling
  preemptible                      = each.value.preemptible
  spot                             = each.value.spot
  spot_instance_termination_action = each.value.spot_instance_termination_action
  automatic_restart                = each.value.automatic_restart
  on_host_maintenance              = each.value.on_host_maintenance
  maintenance_interval             = each.value.maintenance_interval

  # Advanced
  metadata                     = each.value.metadata
  startup_script               = replace(each.value.startup_script, "\r", "")
  enable_nested_virtualization = each.value.enable_nested_virtualization
  threads_per_core             = each.value.threads_per_core
  resource_policies            = each.value.resource_policies

  # "No accelerator type" means no GPU. The remote module gates only on gpu != null, so a
  # block left with a blank type would emit guest_accelerator with a null type and fail apply.
  gpu = try(trimspace(each.value.gpu.type), "") != "" ? each.value.gpu : null
}
