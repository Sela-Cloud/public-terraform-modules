variable "project_id" { type = string }
variable "instance_name" { type = string }
variable "name" { type = string }
variable "type" { type = string }
variable "iam_member" { type = string }
variable "deletion_policy" {
  type    = string
  default = "ABANDON"
}
