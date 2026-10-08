locals {
  backend_project_id = var.backend_project_id == null ? var.project_id : var.backend_project_id

  # A bare name is resolved in project_id; anything with a slash is a self link or projects/...
  # path, which is how a Shared VPC host network and subnet are named from a service project.
  network    = strcontains(var.network, "/") ? var.network : "projects/${var.project_id}/global/networks/${var.network}"
  subnetwork = strcontains(var.subnetwork, "/") ? var.subnetwork : "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"

  certificates = [
    for c in var.certificate_names :
    strcontains(c, "/") ? c : "projects/${var.project_id}/locations/${var.region}/certificates/${c}"
  ]
}

data "google_compute_address" "existing" {
  count   = var.existing_address_name == null ? 0 : 1
  project = var.project_id
  region  = var.region
  name    = var.existing_address_name
}

# SHARED_LOADBALANCER_VIP whether or not the HTTP redirect exists: it is what lets the port-80
# rule share this IP, and fixing it up front means turning the redirect on later never replaces
# the address the load balancer's clients already resolve to.
resource "google_compute_address" "this" {
  count        = var.existing_address_name == null ? 1 : 0
  project      = var.project_id
  region       = var.region
  name         = "${var.name}-ip"
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
  subnetwork   = local.subnetwork
  address      = var.address
  labels       = var.labels
}

locals {
  lb_ip_address = var.existing_address_name == null ? google_compute_address.this[0].address : data.google_compute_address.existing[0].address
}

# A Cloud Run backend is attached through a serverless NEG. The operator picks the service; this
# NEG is pure wiring between that service and this load balancer, so the module creates it.
resource "google_compute_region_network_endpoint_group" "cloud_run" {
  for_each = { for key, svc in var.backend_services : key => svc if svc.target_type == "cloud_run" }

  project               = local.backend_project_id
  name                  = "${each.value.service_name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = each.value.cloud_run_service
  }
}

resource "google_compute_region_health_check" "this" {
  for_each = {
    for key, svc in var.backend_services : key => svc
    if svc.enable_health_check && svc.target_type != "cloud_run"
  }

  project = local.backend_project_id
  region  = var.region
  name    = "${each.value.service_name}-hc"

  check_interval_sec  = each.value.health_check_interval_sec
  timeout_sec         = each.value.health_check_timeout_sec
  healthy_threshold   = each.value.health_check_healthy_threshold
  unhealthy_threshold = each.value.health_check_unhealthy_threshold

  # Exactly one protocol block, so these are mutually exclusive by construction.
  dynamic "tcp_health_check" {
    for_each = each.value.health_check_type == "tcp" ? [1] : []
    content {
      port = each.value.health_check_port
    }
  }

  dynamic "http_health_check" {
    for_each = each.value.health_check_type == "http" ? [1] : []
    content {
      port         = each.value.health_check_port
      request_path = each.value.health_check_request_path
    }
  }
}

resource "google_compute_region_backend_service" "this" {
  for_each = var.backend_services

  project                         = local.backend_project_id
  region                          = var.region
  name                            = each.value.service_name
  protocol                        = "HTTP"
  port_name                       = contains(["umig", "mig"], each.value.target_type) ? each.value.port_name : null
  load_balancing_scheme           = "INTERNAL_MANAGED"
  timeout_sec                     = each.value.timeout_sec
  connection_draining_timeout_sec = 300
  health_checks                   = contains(keys(google_compute_region_health_check.this), each.key) ? [google_compute_region_health_check.this[each.key].id] : null

  backend {
    group = (
      each.value.target_type == "umig" ? "projects/${local.backend_project_id}/zones/${each.value.umig_zone}/instanceGroups/${each.value.umig_name}" :
      each.value.target_type == "mig" ? "projects/${local.backend_project_id}/regions/${var.region}/instanceGroups/${each.value.mig_name}" :
      each.value.target_type == "neg" ? "projects/${local.backend_project_id}/regions/${var.region}/networkEndpointGroups/${each.value.neg_name}" :
      google_compute_region_network_endpoint_group.cloud_run[each.key].id
    )
    # Set for every backend type, serverless included: left unset, the regional resource sends 0,
    # which takes the backend out of rotation for a managed load balancer.
    balancing_mode  = contains(["umig", "mig"], each.value.target_type) ? "UTILIZATION" : null
    capacity_scaler = 1.0
  }

  lifecycle {
    # Cross-variable validation needs Terraform 1.9; a precondition gives the same early, named
    # error on the 1.6 floor. An instance group in another region is otherwise only rejected by
    # the API at apply time.
    precondition {
      condition     = each.value.target_type != "umig" || startswith(each.value.umig_zone, "${var.region}-")
      error_message = "Backend '${each.key}': umig_zone must be a zone of the load balancer's region ${var.region}."
    }
  }
}

locals {
  # Terraform's own "Invalid index" error surfaces a bad key clearly enough; the wrapper also
  # validates every key before planning.
  service_id = { for key, svc in google_compute_region_backend_service.this : key => svc.id }
}

resource "google_compute_region_url_map" "this" {
  project         = var.project_id
  region          = var.region
  name            = "${var.name}-url-map"
  default_service = local.service_id[var.default_service]

  dynamic "host_rule" {
    for_each = var.domains
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.key
    }
  }

  dynamic "path_matcher" {
    for_each = var.domains
    content {
      name            = path_matcher.key
      default_service = local.service_id[path_matcher.value.default_service]

      dynamic "route_rules" {
        for_each = path_matcher.value.route_rules
        content {
          priority = route_rules.value.priority
          service  = local.service_id[route_rules.value.service]

          dynamic "route_action" {
            for_each = (route_rules.value.path_rewrite != null || route_rules.value.path_template_rewrite != null) ? [1] : []
            content {
              url_rewrite {
                path_prefix_rewrite   = route_rules.value.path_rewrite
                path_template_rewrite = route_rules.value.path_template_rewrite
              }
            }
          }

          dynamic "match_rules" {
            for_each = route_rules.value.paths
            content {
              # Prefix matching unless match_mode says otherwise; a path_template_rewrite is the one
              # unambiguous signal that template matching was intended.
              prefix_match        = (route_rules.value.match_mode == "PREFIX_MATCH" || (route_rules.value.match_mode == null && route_rules.value.path_template_rewrite == null)) ? match_rules.value : null
              path_template_match = (route_rules.value.match_mode == "PATH_TEMPLATE_MATCH" || (route_rules.value.match_mode == null && route_rules.value.path_template_rewrite != null)) ? match_rules.value : null
              full_path_match     = route_rules.value.match_mode == "FULL_PATH_MATCH" ? match_rules.value : null
              regex_match         = route_rules.value.match_mode == "REGEX_MATCH" ? match_rules.value : null
            }
          }
        }
      }
    }
  }
}

resource "google_compute_region_target_https_proxy" "this" {
  project                          = var.project_id
  region                           = var.region
  name                             = "${var.name}-https-proxy"
  url_map                          = google_compute_region_url_map.this.id
  certificate_manager_certificates = local.certificates

  lifecycle {
    create_before_destroy = true
  }
}

# An INTERNAL_MANAGED forwarding rule only creates once the network has an active proxy-only
# subnet in this region. That subnet is shared by every Envoy-based load balancer in the region,
# so it is a prerequisite rather than something one load balancer owns.
resource "google_compute_forwarding_rule" "this" {
  project               = var.project_id
  region                = var.region
  name                  = "${var.name}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.this.id
  ip_address            = local.lb_ip_address
  network               = local.network
  subnetwork            = local.subnetwork
  allow_global_access   = var.allow_global_access
  labels                = var.labels
}

resource "google_compute_region_url_map" "http_redirect" {
  count   = var.create_http_redirect ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = "${var.name}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_region_target_http_proxy" "http_redirect" {
  count   = var.create_http_redirect ? 1 : 0
  project = var.project_id
  region  = var.region
  name    = "${var.name}-http-proxy"
  url_map = google_compute_region_url_map.http_redirect[0].id
}

resource "google_compute_forwarding_rule" "http_redirect" {
  count                 = var.create_http_redirect ? 1 : 0
  project               = var.project_id
  region                = var.region
  name                  = "${var.name}-http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.http_redirect[0].id
  ip_address            = local.lb_ip_address
  network               = local.network
  subnetwork            = local.subnetwork
  allow_global_access   = var.allow_global_access
  labels                = var.labels
}
