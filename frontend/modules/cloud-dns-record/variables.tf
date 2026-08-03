variable "project_id" {
  type = string
}

variable "cloud_dns_record" {
  type = map(object({
    record_key   = string
    managed_zone = string
    name         = string
    type         = string
    ttl          = optional(number, 300)
    rrdatas      = list(string)
  }))
  default = {}

  validation {
    condition = length(distinct([
      for record in values(var.cloud_dns_record) : "${lower(trimsuffix(record.name, "."))}|${upper(record.type)}"
    ])) == length(var.cloud_dns_record)
    error_message = "Each Cloud DNS record must have a unique name and type combination."
  }
}
