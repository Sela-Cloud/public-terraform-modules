variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "site_to_site_vpn" {
  description = "Map of Site-to-Site VPN connection configurations to deploy, keyed by name."
  type = map(object({
    name = optional(string, null)

    create_customer_gateway           = optional(bool, true)
    customer_gateway_id               = optional(string, null)
    customer_gateway_ip_address       = optional(string, null)
    customer_gateway_bgp_asn          = optional(string, null)
    customer_gateway_bgp_asn_extended = optional(string, null)
    customer_gateway_certificate_arn  = optional(string, null)
    customer_gateway_device_name      = optional(string, null)

    vpn_gateway_id     = optional(string, null)
    transit_gateway_id = optional(string, null)

    static_routes_only                      = optional(bool, false)
    enable_acceleration                     = optional(bool, false)
    local_ipv4_network_cidr                 = optional(string, null)
    local_ipv6_network_cidr                 = optional(string, null)
    remote_ipv4_network_cidr                = optional(string, null)
    remote_ipv6_network_cidr                = optional(string, null)
    outside_ip_address_type                 = optional(string, null)
    transport_transit_gateway_attachment_id = optional(string, null)
    tunnel_inside_ip_version                = optional(string, null)
    tunnel_bandwidth                        = optional(string, null)
    preshared_key_storage                   = optional(string, null)

    tunnel1 = optional(object({
      inside_cidr                     = optional(string, null)
      inside_ipv6_cidr                = optional(string, null)
      preshared_key                   = optional(string, null)
      dpd_timeout_action              = optional(string, null)
      dpd_timeout_seconds             = optional(number, null)
      ike_versions                    = optional(list(string), null)
      phase1_dh_group_numbers         = optional(list(number), null)
      phase1_encryption_algorithms    = optional(list(string), null)
      phase1_integrity_algorithms     = optional(list(string), null)
      phase1_lifetime_seconds         = optional(number, null)
      phase2_dh_group_numbers         = optional(list(number), null)
      phase2_encryption_algorithms    = optional(list(string), null)
      phase2_integrity_algorithms     = optional(list(string), null)
      phase2_lifetime_seconds         = optional(number, null)
      rekey_fuzz_percentage           = optional(number, null)
      rekey_margin_time_seconds       = optional(number, null)
      replay_window_size              = optional(number, null)
      startup_action                  = optional(string, null)
      enable_tunnel_lifecycle_control = optional(bool, null)
      cloudwatch_log_options = optional(object({
        log_enabled           = optional(bool, null)
        log_group_arn         = optional(string, null)
        log_output_format     = optional(string, null)
        bgp_log_enabled       = optional(bool, null)
        bgp_log_group_arn     = optional(string, null)
        bgp_log_output_format = optional(string, null)
      }), null)
    }), {})

    tunnel2 = optional(object({
      inside_cidr                     = optional(string, null)
      inside_ipv6_cidr                = optional(string, null)
      preshared_key                   = optional(string, null)
      dpd_timeout_action              = optional(string, null)
      dpd_timeout_seconds             = optional(number, null)
      ike_versions                    = optional(list(string), null)
      phase1_dh_group_numbers         = optional(list(number), null)
      phase1_encryption_algorithms    = optional(list(string), null)
      phase1_integrity_algorithms     = optional(list(string), null)
      phase1_lifetime_seconds         = optional(number, null)
      phase2_dh_group_numbers         = optional(list(number), null)
      phase2_encryption_algorithms    = optional(list(string), null)
      phase2_integrity_algorithms     = optional(list(string), null)
      phase2_lifetime_seconds         = optional(number, null)
      rekey_fuzz_percentage           = optional(number, null)
      rekey_margin_time_seconds       = optional(number, null)
      replay_window_size              = optional(number, null)
      startup_action                  = optional(string, null)
      enable_tunnel_lifecycle_control = optional(bool, null)
      cloudwatch_log_options = optional(object({
        log_enabled           = optional(bool, null)
        log_group_arn         = optional(string, null)
        log_output_format     = optional(string, null)
        bgp_log_enabled       = optional(bool, null)
        bgp_log_group_arn     = optional(string, null)
        bgp_log_output_format = optional(string, null)
      }), null)
    }), {})

    routes = optional(list(object({
      key                    = string
      destination_cidr_block = string
    })), [])

    tags = optional(map(string), {})
  }))
  default = {}
}
