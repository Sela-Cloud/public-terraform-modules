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

output "name" {
  description = "The name of the COmpute Instance created."
  value       = google_compute_instance.gce_vm[*].name
}

output "compute_instance_id" {
  description = "The ID of the Compute Instance created."
  value       = google_compute_instance.gce_vm[*].id
}

output "machine_zone" {
  description = "The zone of the Compute Instance created."
  value       = google_compute_instance.gce_vm[*].zone
}

# output "gce_data_disk01" {
#   description = "The GCE ID of the Disk created."
#   value       = google_compute_disk.gce_data_disk01
# }

# output "gce_data_disk02" {
#   description = "The GCE ID of the Disk created."
#   value       = google_compute_disk.gce_data_disk01
# }

# output "gce_data_disk03" {
#   description = "The GCE ID of the Disk created."
#   value       = google_compute_disk.gce_data_disk01
# }

# output "gce_disk_name" {
#   description = "The name of the GCE Disk created."
#   value       = google_compute_disk.gce_data_disk01
# }



