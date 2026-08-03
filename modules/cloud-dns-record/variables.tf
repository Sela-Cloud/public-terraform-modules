variable "project_id" { type = string }
variable "managed_zone" { type = string }
variable "name" { type = string }
variable "type" { type = string }
variable "ttl" {
  type    = number
  default = 300
}
variable "rrdatas" { type = list(string) }
