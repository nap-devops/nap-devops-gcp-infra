# forwarding rule
resource "google_compute_forwarding_rule" "http_fwd_rule" {
  name                  = "${var.prefix}-${var.name}"
  provider              = google-beta
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.target_proxy.id
  network               = var.network
  subnetwork            = var.subnetwork
  network_tier          = "PREMIUM"
  allow_global_access   = false
  service_label         = var.prefix
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "target_proxy" {
  name     = "${var.prefix}-${var.name}-proxy"
  provider = google-beta
  region   = var.region
  url_map  = google_compute_region_url_map.default.id
}

# URL map
resource "google_compute_region_url_map" "default" {
  name            = "${var.prefix}-${var.name}-lb"
  provider        = google-beta
  region          = var.region
  default_service = google_compute_region_backend_service.default.id
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "${var.prefix}-${var.name}-bn"
  provider              = google-beta
  region                = var.region
  protocol              = "HTTP"
  port_name             = var.backend_port_name

  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = var.is_tcp_healthcheck ? [google_compute_region_health_check.tcp_hc.self_link] : [google_compute_region_health_check.default.self_link]  

  dynamic "backend" {
    for_each = var.instances_zones
    content {
      group = "projects/${var.project}/zones/${var.region}-${backend.value}/instanceGroups/${var.isg_prefix}-group-${var.region}-${backend.value}"
      balancing_mode = "UTILIZATION"
      capacity_scaler = 1.0
    }
  }
}

# health check
resource "google_compute_region_health_check" "default" {
  name     = "${var.prefix}-${var.name}-hc"
  provider = google-beta
  region   = var.region

  http_health_check {
    port         = var.health_check_port
    request_path = "/"
  }

  check_interval_sec = 5
  timeout_sec        = 5  
}
 
resource "google_compute_region_health_check" "tcp_hc" {
  name     = "${var.prefix}-${var.name}-tcp-hc"
  provider = google-beta
  region   = var.region

  tcp_health_check {
    port         = var.health_check_port
  }

  check_interval_sec = 5
  timeout_sec        = 5  
}
