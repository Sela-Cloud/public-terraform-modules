#########
# Locals
#########
locals {
  external_ip_add     = var.enable_external_ip ? 1 : 0
  access_config       = local.external_ip_add != 0 ? [true] : []
  shielded_vm_configs = var.enable_shielded_vm ? [true] : []
  instance_group_count = min(
    var.instance_count,
    length(var.zone)
  )
}

data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
  status  = "UP"
}

# #########################
# Google Static Internal IP
# #########################
resource "google_compute_address" "static_internal_ip_address" {
  count        = var.instance_count
  name         = "${var.machine_name}-int-ip-${count.index + 1}"
  address      = var.generate_internal_ip ? null : var.internal_ip_address[count.index]
  address_type = "INTERNAL"
  project      = var.project
  subnetwork   = var.subnetwork
  region       = var.region
  lifecycle {
    prevent_destroy = true
  }
}

# #########################
# Google Static External IP
# #########################
resource "google_compute_address" "static_external_ip_address" {
  count        = local.external_ip_add
  name         = "${var.machine_name}-ext-ip"
  address_type = "EXTERNAL"
  project      = var.project
  region       = var.region
  lifecycle {
    prevent_destroy = true
  }
}

###################
# Google Compute VM
###################
resource "google_compute_instance" "gce_vm" {
  count        = var.instance_count
  name         = var.machine_name
  project      = var.project
  machine_type = var.machine_type
  description  = var.vm_description
  zone         = element(var.zone, count.index)

  allow_stopping_for_update = true
  deletion_protection       = var.vm_deletion_protect

  tags = var.network_tags

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.boot_gce_disk[count.index].id
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    network_ip = google_compute_address.static_internal_ip_address[count.index].id

    dynamic "access_config" {
      for_each = local.access_config
      content {
        nat_ip       = google_compute_address.static_external_ip_address[0].address
        network_tier = "PREMIUM"
      }
    }
  }

  lifecycle {
    ignore_changes = [attached_disk, network_interface["network_ip"], metadata["ssh-keys"]]
  }

  labels         = var.instance_labels
  hostname       = "${var.machine_name}.${var.zone[count.index % length(var.zone)]}.c.${var.project}.internal"
  can_ip_forward = var.can_ip_forward

  dynamic "service_account" {
    for_each = [var.service_account]
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  metadata                = var.metadata
  metadata_startup_script = var.metadata_startup_script

  dynamic "shielded_instance_config" {
    for_each = local.shielded_vm_configs
    content {
      enable_secure_boot          = lookup(var.shielded_instance_config, "enable_secure_boot", shielded_instance_config.value)
      enable_vtpm                 = lookup(var.shielded_instance_config, "enable_vtpm", shielded_instance_config.value)
      enable_integrity_monitoring = lookup(var.shielded_instance_config, "enable_integrity_monitoring", shielded_instance_config.value)
    }
  }

  depends_on = [google_compute_address.static_external_ip_address]


}

######################################
# Google Compute VM Boot Disk Creation
######################################
resource "google_compute_disk" "boot_gce_disk" {
  count   = var.instance_count
  name    = "${var.machine_name}-boot-disk"
  size    = var.boot_disk_info["disk_size_gb"]
  type    = var.boot_disk_info["disk_type"]
  zone    = element(var.zone, count.index)
  project = var.project
  image   = var.instance_image_selflink

  labels = merge(
    var.disk_labels,
    tomap({ "type" = "boot" })

  )
  physical_block_size_bytes = 4096
}

###############################################
# Snapshot Policy Attachment for Boot Disks
###############################################
resource "google_compute_disk_resource_policy_attachment" "boot_diskpolicy_attach" {
  count   = var.snapshot_policy_name == null ? 0 : var.instance_count
  name    = var.snapshot_policy_name
  project = var.project
  disk    = google_compute_disk.boot_gce_disk[count.index].name
  zone    = element(var.zone, count.index)
}

#################################
# Create compute engine data disk
#################################

resource "google_compute_disk" "gce_data_disk" {
  count   = var.data_disk == null ? 0 : var.instance_count * length(var.data_disk)
  name    = "${var.machine_name}-boot-disk"
  size    = var.data_disk[count.index % length(var.data_disk)].disk_size_gb
  type    = var.data_disk[count.index % length(var.data_disk)].disk_type
  project = var.project
  zone    = google_compute_instance.gce_vm[floor(count.index / length(var.data_disk))].zone
  labels = merge(
    var.disk_labels,
    tomap({ "type" = "boot" })
  )
  physical_block_size_bytes = 4096
  lifecycle {
    ignore_changes  = [name]
    prevent_destroy = true
  }
}

##########################################
# Google Compute VM & Data Disk Attachment
##########################################

resource "google_compute_attached_disk" "gce_data_disk_attach" {
  count      = var.data_disk == null ? 0 : var.instance_count * length(var.data_disk)
  disk       = google_compute_disk.gce_data_disk[count.index].id
  instance   = google_compute_instance.gce_vm[floor(count.index / length(var.data_disk))].id
  depends_on = [google_compute_disk.gce_data_disk]
}

###############################################
# Snapshot Policy Attachment for Attached Disks
###############################################

resource "google_compute_disk_resource_policy_attachment" "gce_data_disk_policy_attach" {
  count   = var.snapshot_policy_name == null ? 0 : var.instance_count * length(var.data_disk)
  name    = var.snapshot_policy_name
  project = var.project
  disk    = google_compute_disk.gce_data_disk[count.index].name
  zone    = google_compute_instance.gce_vm[floor(count.index / length(var.data_disk))].zone
}