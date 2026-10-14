################################################################################
# General
################################################################################

variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
}

################################################################################
# Customer Gateway (the on-premises side)
################################################################################

variable "create_customer_gateway" {
  description = "Whether to create a Customer Gateway. If false, customer_gateway_id must reference an existing one."
  type        = bool
  default     = true
}

variable "customer_gateway_id" {
  description = "Existing Customer Gateway ID. Required if create_customer_gateway is false."
  type        = string
  default     = null
}

variable "customer_gateway_ip_address" {
  description = "The IPv4 address for the customer gateway device's outside interface."
  type        = string
  default     = null
}

variable "customer_gateway_bgp_asn" {
  description = "The customer gateway's BGP ASN (1 to 2147483647). Mutually exclusive with customer_gateway_bgp_asn_extended."
  type        = string
  default     = null
}

variable "customer_gateway_bgp_asn_extended" {
  description = "The customer gateway's extended-range BGP ASN (2147483648 to 4294967295). Mutually exclusive with customer_gateway_bgp_asn."
  type        = string
  default     = null
}

variable "customer_gateway_certificate_arn" {
  description = "ARN of the customer gateway's private certificate, for certificate-based authentication instead of a pre-shared key."
  type        = string
  default     = null
}

variable "customer_gateway_device_name" {
  description = "A name for the customer gateway device, for your own reference."
  type        = string
  default     = null
}

################################################################################
# VPN Connection Target (exactly one of these two)
################################################################################

variable "vpn_gateway_id" {
  description = "ID of the Virtual Private Gateway to attach the VPN connection to. Exactly one of vpn_gateway_id or transit_gateway_id is required."
  type        = string
  default     = null
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach the VPN connection to. Exactly one of vpn_gateway_id or transit_gateway_id is required."
  type        = string
  default     = null
}

################################################################################
# VPN Connection
################################################################################

variable "static_routes_only" {
  description = "Use static routes exclusively, for customer gateway devices that don't support BGP. When false, the connection uses dynamic BGP routing."
  type        = bool
  default     = false
}

variable "enable_acceleration" {
  description = "Enable acceleration for the VPN connection. Only valid when attached to a Transit Gateway."
  type        = bool
  default     = false
}

variable "local_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the AWS side of the VPN connection."
  type        = string
  default     = null
}

variable "local_ipv6_network_cidr" {
  description = "The IPv6 CIDR on the AWS side of the VPN connection."
  type        = string
  default     = null
}

variable "remote_ipv4_network_cidr" {
  description = "The IPv4 CIDR on the customer gateway side of the VPN connection."
  type        = string
  default     = null
}

variable "remote_ipv6_network_cidr" {
  description = "The IPv6 CIDR on the customer gateway side of the VPN connection."
  type        = string
  default     = null
}

variable "outside_ip_address_type" {
  description = "Indicates if the VPN tunnels process IPv4 or IPv6 traffic. 'PrivateIpv4' requires transport_transit_gateway_attachment_id to be set."
  type        = string
  default     = null
}

variable "transport_transit_gateway_attachment_id" {
  description = "Required when outside_ip_address_type is 'PrivateIpv4' -- the Transit Gateway attachment used to connect over a private network."
  type        = string
  default     = null
}

variable "tunnel_inside_ip_version" {
  description = "Indicates whether the VPN tunnels process IPv4 or IPv6 traffic. 'ipv4' or 'ipv6'."
  type        = string
  default     = null
}

variable "tunnel_bandwidth" {
  description = "Tunnel bandwidth, e.g. 'standard' (1.25 Gbps) or 'high-performance' (5 Gbps, Transit Gateway only). Not supported with vpn_gateway_id or when enable_acceleration is true."
  type        = string
  default     = null
}

variable "preshared_key_storage" {
  description = "Where to store the tunnels' pre-shared keys. Leave null to keep them in the Terraform state (default AWS behavior); set to 'SecretsManager' to store them there instead."
  type        = string
  default     = null
}

################################################################################
# Tunnel Options (one object per tunnel; AWS fills in sensible defaults for
# anything left null -- see each tunnel's own variable description)
################################################################################

variable "tunnel1" {
  description = "Tunnel 1 options. Every field is optional; AWS assigns its own sensible default (e.g. Phase 1 lifetime 28800s, Phase 2 lifetime 3600s, DPD timeout 30s, startup action 'add') for anything left null."
  type = object({
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
  })
  default = {}
}

variable "tunnel2" {
  description = "Tunnel 2 options. Same shape and defaulting behavior as tunnel1."
  type = object({
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
  })
  default = {}
}

################################################################################
# Static Routes (only meaningful when static_routes_only = true)
################################################################################

variable "routes" {
  description = "Static routes for the VPN connection. Only meaningful when static_routes_only is true -- with BGP dynamic routing, AWS determines routes automatically. Each needs a unique key (Terraform-only, not sent to AWS)."
  type = list(object({
    key                    = string
    destination_cidr_block = string
  }))
  default = []
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
