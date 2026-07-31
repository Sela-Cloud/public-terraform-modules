variable "project_id" { type = string }
variable "name" { type = string }
variable "network" { type = string }
variable "prefix_length" {
  type    = number
  default = 20
}
variable "address" {
  type    = string
  default = null
}
