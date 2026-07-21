# Custom Compute Engine module


This module makes it easy to create one or more Linux based Compute engine instance with External IP, Boot disk, Additional Disk.

## Compatibility

This module is meant for use with Terraform 0.13.

## Inputs


| Name | Description | Type | 
|------|-------------|------|
| name | The name of the vm | string |
| machine_type | Type of VM which will be deployed such as n1-standrad-1. | string |
| deletion_protection | Prevent vm from deletion | string |
| zone | Zone of the disk | string |
| network_tags | Attach network tag, Network tag allows to enforce firewall rule on this vm | string |
| labels | Key-value map of labels to assign to vm | map |
| metadata | Key-value map of labels to assign to vm, it can be startup script or shutdown script for vm | map |
| network | VPC network on which vm will be deployed | string |
| subnetwork | VPC sub-network on which vm will be deployed | string |
| network_ip | Static external ip to be attached to vm. External IP can be static or ephemeral  | string |
| nat_ip  | NAT Gateway to be attached on vm, to connect with internet  | string |
| service_account | Service account to be attached to the vm. | string |


## Outputs

| Name | Description |
|------|-------------|
| name | The name of the COmpute Instance created. |
| compute\_instance\_id | The ID of the Compute Instance created. |
| machine\_zone | The zone of the Compute Instance created. |
| gce_disk_id | The GCE ID of the Disk created. |
| gce_disk_name | The name of the GCE Disk created. |


## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.12
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

User or service account credentials with the following roles must be used to provision the resources of this module:

- Compute Admin: `roles/compute.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Compute instances - `compute.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html


