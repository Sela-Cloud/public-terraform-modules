variable "project_id" { type = string }
variable "name" { type = string }
variable "dns_name" { type = string }
variable "visibility" {
  type    = string
  default = "public"
}
variable "description" {
  type    = string
  default = null
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "private_networks" {
  type    = list(string)
  default = []
}
variable "enable_logging" {
  type    = bool
  default = false
}
