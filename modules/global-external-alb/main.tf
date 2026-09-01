locals {
  backend_project_id = var.backend_project_id == null ? var.project_id : var.backend_project_id

  service_ref = { for key, svc in var.backend_services : key => svc }
  bucket_ref  = { for key, bkt in var.backend_buckets : key => bkt }
}

data "google_compute_global_address" "existing" {
  count   = var.existing_static_ip_name == null ? 0 : 1
  project = var.project_id
  name    = var.existing_static_ip_name
}

resource "google_compute_global_address" "this" {
  count   = var.existing_static_ip_name == null ? 1 : 0
  project = var.project_id
  name    = "${var.name}-ip"
}

locals {
  lb_ip_address = var.existing_static_ip_name == null ? google_compute_global_address.this[0].address : data.google_compute_global_address.existing[0].address
}

resource "google_compute_backend_bucket" "this" {
  for_each = var.backend_buckets

  project     = local.backend_project_id
  name        = each.value.bucket_name
  description = each.value.description
  bucket_name = each.value.gcs_bucket_name
  enable_cdn  = each.value.enable_cdn

  dynamic "cdn_policy" {
    for_each = each.value.cdn_policy != null ? [each.value.cdn_policy] : []
    content {
      cache_mode        = cdn_policy.value.cache_mode
      default_ttl       = cdn_policy.value.default_ttl
      max_ttl           = cdn_policy.value.max_ttl
      client_ttl        = cdn_policy.value.client_ttl
      negative_caching  = cdn_policy.value.negative_caching
      serve_while_stale = cdn_policy.value.serve_while_stale

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_http_headers   = cache_key_policy.value.include_http_headers
          query_string_whitelist = cache_key_policy.value.query_string_whitelist
        }
      }
    }
  }
}

resource "google_compute_health_check" "this" {
  for_each = { for key, svc in var.backend_services : key => svc if svc.enable_health_check }

  project = local.backend_project_id
  name    = "${each.value.service_name}-hc"

  tcp_health_check {
    port = each.value.health_check_port
  }
}

resource "google_compute_backend_service" "this" {
  for_each = var.backend_services

  project                         = local.backend_project_id
  name                            = each.value.service_name
  protocol                        = "HTTP"
  port_name                       = each.value.target_type == "umig" ? each.value.port_name : null
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 300
  enable_cdn                      = each.value.enable_cdn
  health_checks                   = each.value.enable_health_check ? [google_compute_health_check.this[each.key].id] : null

  backend {
    group = each.value.target_type == "umig" ? (
      "https://www.googleapis.com/compute/v1/projects/${local.backend_project_id}/zones/${each.value.umig_zone}/instanceGroups/${each.value.umig_name}"
      ) : (
      "https://www.googleapis.com/compute/v1/projects/${local.backend_project_id}/regions/${each.value.neg_region}/networkEndpointGroups/${each.value.neg_name}"
    )
    balancing_mode  = each.value.target_type == "umig" ? "UTILIZATION" : null
    capacity_scaler = each.value.target_type == "umig" ? 1.0 : null
  }

  dynamic "cdn_policy" {
    for_each = each.value.cdn_policy != null ? [each.value.cdn_policy] : []
    content {
      cache_mode        = cdn_policy.value.cache_mode
      default_ttl       = cdn_policy.value.default_ttl
      max_ttl           = cdn_policy.value.max_ttl
      client_ttl        = cdn_policy.value.client_ttl
      negative_caching  = cdn_policy.value.negative_caching
      serve_while_stale = cdn_policy.value.serve_while_stale

      dynamic "cache_key_policy" {
        for_each = cdn_policy.value.cache_key_policy != null ? [cdn_policy.value.cache_key_policy] : []
        content {
          include_host           = cache_key_policy.value.include_host
          include_protocol       = cache_key_policy.value.include_protocol
          include_query_string   = cache_key_policy.value.include_query_string
          query_string_blacklist = cache_key_policy.value.query_string_blacklist
          query_string_whitelist = cache_key_policy.value.query_string_whitelist
          include_http_headers   = cache_key_policy.value.include_http_headers
          include_named_cookies  = cache_key_policy.value.include_named_cookies
        }
      }
    }
  }
}

locals {
  # Resolves a {type,key} reference to the matching backend resource id.
  # Terraform's own "Invalid index" error surfaces a bad key clearly enough
  # given required_version >= 1.6.1 predates cross-variable validation (1.9+).
  service_or_bucket_id = { for pair in flatten(concat(
    [for key, svc in var.backend_services : { key = "service:${key}", id = google_compute_backend_service.this[key].id }],
    [for key, bkt in var.backend_buckets : { key = "bucket:${key}", id = google_compute_backend_bucket.this[key].id }]
    )) : pair.key => pair.id
  }

  default_service_id = local.service_or_bucket_id["${var.default_service.type}:${var.default_service.key}"]
}

resource "google_compute_url_map" "this" {
  project         = var.project_id
  name            = "${var.name}-url-map"
  default_service = local.default_service_id

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
      default_service = local.service_or_bucket_id["${path_matcher.value.default_service.type}:${path_matcher.value.default_service.key}"]

      dynamic "route_rules" {
        for_each = path_matcher.value.route_rules
        content {
          priority = route_rules.value.priority
          service  = local.service_or_bucket_id["${route_rules.value.service.type}:${route_rules.value.service.key}"]

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
              # Default to prefix matching when match_mode is unset -- the sensible default for
              # plain path routing. A path_template_rewrite is the one unambiguous signal that
              # path-template matching was actually intended (path_prefix_rewrite only works with
              # prefix_match anyway, so path_rewrite alone must not flip the default away from it).
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

resource "google_compute_target_https_proxy" "this" {
  project         = var.project_id
  name            = "${var.name}-https-proxy"
  url_map         = google_compute_url_map.this.id
  certificate_map = "//certificatemanager.googleapis.com/projects/${var.project_id}/locations/global/certificateMaps/${var.certificate_map_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_forwarding_rule" "this" {
  project               = var.project_id
  name                  = "${var.name}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.this.id
  ip_address            = local.lb_ip_address
}

resource "google_compute_url_map" "http_redirect" {
  count   = var.create_http_redirect ? 1 : 0
  project = var.project_id
  name    = "${var.name}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_redirect" {
  count   = var.create_http_redirect ? 1 : 0
  project = var.project_id
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.http_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  count                 = var.create_http_redirect ? 1 : 0
  project               = var.project_id
  name                  = "${var.name}-http-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http_redirect[0].id
  ip_address            = local.lb_ip_address
}
