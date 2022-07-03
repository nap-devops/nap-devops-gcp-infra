# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A HTTP LOAD BALANCER
# This module deploys a HTTP(S) Cloud Load Balancer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# CREATE A PUBLIC IP ADDRESS
# ------------------------------------------------------------------------------

resource "google_compute_global_address" "default" {
  project      = var.project
  name         = "${var.name}-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

# ------------------------------------------------------------------------------
# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "http" {
  count   = var.enable_http ? 1 : 0
  project = var.project
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  provider   = google-beta
  count      = var.enable_http ? 1 : 0
  project    = var.project
  name       = "${var.name}-http-rule"
  target     = google_compute_target_http_proxy.http[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "80"

  depends_on = [google_compute_global_address.default]

  labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# IF SSL ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

resource "google_compute_global_forwarding_rule" "https" {
  provider   = google-beta
  project    = var.project
  count      = var.enable_ssl ? 1 : 0
  name       = "${var.name}-https-rule"
  target     = google_compute_target_https_proxy.default[0].self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  depends_on = [google_compute_global_address.default]

  labels = var.custom_labels
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project
  count   = var.enable_ssl ? 1 : 0
  name    = "${var.name}-https-proxy"
  url_map = google_compute_url_map.urlmap.self_link

  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.id]
}

# ------------------------------------------------------------------------------
# IF DNS ENTRY REQUESTED, CREATE A RECORD POINTING TO THE PUBLIC IP OF THE CLB
# ------------------------------------------------------------------------------

resource "google_dns_record_set" "dns" {
  project = var.project
  count   = var.create_dns_entries ? length(var.custom_domain_names) : 0

  name = "${element(var.custom_domain_names, count.index)}."
  type = "A"
  ttl  = var.dns_record_ttl

  managed_zone = var.dns_managed_zone_name

  rrdatas = [google_compute_global_address.default.address]
}


####


# ------------------------------------------------------------------------------
# CREATE THE URL MAP TO MAP PATHS TO BACKENDS
# ------------------------------------------------------------------------------

resource "google_compute_url_map" "urlmap" {
  project = var.project

  name        = "${var.prefix}-${var.name}-lb"
  description = "URL map for ${var.name}"

  default_service = google_compute_backend_service.bn.self_link

  #host_rule {
  #  hosts        = ["*"]
  #  path_matcher = "all"
  #}

  #path_matcher {
  #  name            = "all"
  #  default_service = google_compute_backend_service.api.self_link

  #  path_rule {
  #    paths   = ["/*"]
  #    service = google_compute_backend_service.api.self_link
  #  }
  #}
}

# ------------------------------------------------------------------------------
# CREATE THE BACKEND SERVICE CONFIGURATION FOR THE INSTANCE GROUP
# ------------------------------------------------------------------------------

resource "google_compute_backend_service" "bn" {
  project = var.project

  name        = "${var.name}-api"
  description = "API Backend for ${var.name}"
  port_name   = var.backend_port_name
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  dynamic "backend" {
    for_each = var.instances_regions
    content {
      group = "projects/${var.project}/zones/${backend.value}-a/instanceGroups/${var.isg_prefix}-group-${backend.value}-a"
    }
  }

  dynamic "backend" {
    for_each = var.instances_regions
    content {
      group = "projects/${var.project}/zones/${backend.value}-b/instanceGroups/${var.isg_prefix}-group-${backend.value}-b"
    }
  }

  dynamic "backend" {
    for_each = var.instances_regions
    content {
      group = "projects/${var.project}/zones/${backend.value}-c/instanceGroups/${var.isg_prefix}-group-${backend.value}-c"
    }
  }

  health_checks = var.is_tcp_healthcheck ? [google_compute_health_check.tcp_hc.self_link] : [google_compute_health_check.default.self_link]  
}

# ------------------------------------------------------------------------------
# CONFIGURE HEALTH CHECK FOR THE API BACKEND
# ------------------------------------------------------------------------------

resource "google_compute_health_check" "default" {
  project = var.project
  name    = "${var.name}-hc"

  #is_tcp_healthcheck = false
  http_health_check {
    port         = var.health_check_port
    request_path = "/"
  }

  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_health_check" "tcp_hc" {
  project = var.project
  name    = "${var.name}-tcp-hc"

  tcp_health_check {
    port = var.health_check_port
  }

  check_interval_sec = 5
  timeout_sec        = 5
}

resource "google_compute_managed_ssl_certificate" "certificate" {
  name = "${var.prefix}-${var.name}-cert"

  managed {
    domains = var.custom_domain_names
  }
}