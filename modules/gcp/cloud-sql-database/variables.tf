variable "project_id" { type = string }
variable "instance_name" { type = string }
variable "name" { type = string }
variable "charset" {
  type    = string
  default = null
}
variable "collation" {
  type    = string
  default = null
}
variable "deletion_policy" {
  type    = string
  default = "ABANDON"
}
