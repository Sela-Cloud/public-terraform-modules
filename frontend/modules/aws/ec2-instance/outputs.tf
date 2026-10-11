output "ec2_instance" {
  description = "The details of the EC2 instances created, excluding the sensitive generated private key fields -- see ec2_instance_private_keys for those."
  value = {
    for k, v in module.ec2_instance : k => merge(v, {
      private_key_pem     = null
      private_key_openssh = null
    })
  }
}

output "ec2_instance_private_keys" {
  description = "Map of instance identifiers to their generated private key material (PEM and OpenSSH), when the module generated a key pair."
  value = {
    for k, v in module.ec2_instance : k => {
      private_key_pem     = v.private_key_pem
      private_key_openssh = v.private_key_openssh
    }
  }
  sensitive = true
}
