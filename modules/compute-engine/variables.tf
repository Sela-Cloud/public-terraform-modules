/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#################
# Global variables
#################
variable "project" {
  type        = string
  description = "The GCP project ID"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
}

variable "instance_image_selflink" {
  description = "Compute Image to use, e.g. projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20200610. Get it from console REST Response"
}

variable "machine_name" {
  description = "Hostname of instances"
}

variable "hostname" {
  description = "A custom hostname for the instance."
  default     = ""
}

variable "vm_description" {
  type        = string
  description = "Description of instances"
}

variable "zone" {
  type        = list(string)
  description = "Zone where the instances should be created. If not specified, instances will be spread across available zones in the region."
  default     = ["asia-south2-a", "asia-south2-b", "asia-south2-c"]
}

variable "network_tags" {
  description = "Network tags, provided as a list"
}

variable "region" {
  type        = string
  description = "Region where the instance template and instance should be created."
}

variable "instance_count" {
  type        = number
  description = ""
}

############
# disk - details
############
variable "boot_disk_info" {
  description = "The information of boot disk of GCE instance."
}

variable "vm_deletion_protect" {
  type        = bool
  description = "The prevent deletion of a GCE instance on accidental terraform destroy or from console"
  default     = true
}

variable "snapshot_policy_name" {
  description = "The name of the snapshot_policy_name to attach this disk to"
  default     = null
}

####################
# network-interface
####################
variable "network" {
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
  default     = ""
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  default     = ""
}

##################
# Service Account
##################
variable "service_account" {
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance."
}

###########################
# Static External IP
###########################
variable "enable_external_ip" {
  type        = bool
  description = "Instance External IP required or not"
  default     = false
}

###########################
# Static Internal IP
###########################

variable "generate_internal_ip" {
  type        = bool
  description = "Instance Internal IP required or not"
  default     = true
}

variable "internal_ip_address" {
  type        = list(string)
  description = "Instance Internal IP address"
  default     = [""]
}

##################
# Labels
##################

variable "instance_labels" {
  type        = map(string)
  description = "Instance Labels, provided as a map"
  default     = {}
}


variable "disk_labels" {
  type        = map(string)
  description = "Disk Labels, provided as a map"
  default     = {}
}

###########
# Metadata
###########

variable "metadata" {
  type        = map(string)
  description = "Metadata, provided as a map"
  default     = {}
}

variable "metadata_startup_script" {
  type        = string
  description = "Startup script provided as a string"
  default     = null
}

variable "can_ip_forward" {
  type        = bool
  description = "Whether to enable IP forwarding for the instance"
  default     = null
}

##################
# Additional Disk
##################

# variable "data_disk01" {
#   description = "The information of Data disk of GCE instance."
#   default = null
# }

# variable "data_disk02" {
#   description = "The information of Data disk of GCE instance."
#   default = null
# }

# variable "data_disk03" {
#   description = "The information of Data disk of GCE instance."
#   default = null
# }

variable "enable_data_disk" {
  default = false
}

variable "data_disk" {
  type = list(object({
    disk_type    = string
    disk_size_gb = number
  }))
  default = null
}


###########################
# Shielded VMs
###########################
variable "enable_shielded_vm" {
  default     = true
  description = "Whether to enable the Shielded VM configuration on the instance. Note that the instance image must support Shielded VMs. See https://cloud.google.com/compute/docs/images"
}

variable "shielded_instance_config" {
  description = "Not used unless enable_shielded_vm is true. Shielded VM configuration for the instance."
  type = object({
    enable_secure_boot          = bool
    enable_vtpm                 = bool
    enable_integrity_monitoring = bool
  })

  default = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

###########################
# Umig
###########################




