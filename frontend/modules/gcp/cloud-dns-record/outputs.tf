output "records" {
  value = {
    for key, record in module.cloud_dns_record : key => record.id
  }
}
