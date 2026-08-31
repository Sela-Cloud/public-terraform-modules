/******************************************
  Details of Compute Engine
 *****************************************/

module "compute_instance" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/compute-engine?ref=v0.6.8"
  for_each = var.compute_instance
  project  = var.project
  region   = each.value.region
  # One tfvars entry is one VM (MODULE_CONTRACT R1). The remote module still counts on this
  # input, so it is pinned rather than removed, which keeps addresses at [0].
  instance_count          = 1
  machine_name            = each.value.machine_name
  can_ip_forward          = each.value.can_ip_forward
  vm_description          = each.value.vm_description
  enable_external_ip      = each.value.enable_external_ip
  generate_internal_ip    = each.value.generate_internal_ip
  internal_ip_address     = each.value.internal_ip_address
  machine_type            = each.value.machine_type
  zone                    = each.value.machine_zone
  instance_labels         = each.value.instance_labels
  vm_deletion_protect     = each.value.vm_deletion_protect
  instance_image_selflink = each.value.instance_image_selflink
  network                 = each.value.network
  subnetwork              = each.value.subnetwork
  network_tags            = each.value.network_tags
  boot_disk_info          = each.value.boot_disk0_info
  service_account         = each.value.service_account
  metadata                = each.value.metadata
  metadata_startup_script = each.value.metadata_startup_script != null ? replace(each.value.metadata_startup_script, "\r", "") : null

  # Data disks. The remote module declares enable_data_disk but never reads it --
  # it gates purely on data_disk -- so honour the UI toggle here. An empty list
  # (rather than null) keeps length() safe in the snapshot-policy attachment count.
  enable_data_disk = each.value.enable_data_disk
  data_disk        = each.value.enable_data_disk ? coalesce(each.value.data_disk, []) : []
  disk_labels      = each.value.disk_labels

  # The remote module treats only null as "no snapshot policy"; the UI sends ""
  # for an untouched text field, which would create a policy with an empty name.
  snapshot_policy_name = each.value.snapshot_policy_name != "" ? each.value.snapshot_policy_name : null

  # The remote module lookup()s into shielded_instance_config whenever
  # enable_shielded_vm is true, so it must never be null there.
  enable_shielded_vm = each.value.enable_shielded_vm
  shielded_instance_config = coalesce(each.value.shielded_instance_config, {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  })
}
