resource "google_compute_global_address" "gke_ingress_1" {
  project      = var.project
  name         = "gke-ingress-1"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "gke_ingress_1_dns_wildcard" {
  project = var.project

  name = "*.${var.top_level_domain}."
  type = "A"
  ttl  = 300
  managed_zone = "devops"

  rrdatas = [google_compute_global_address.gke_ingress_1.address]
}

# SysLog service
resource "google_compute_address" "gke_syslog_svc_1" {
  project      = var.project
  name         = "gke-syslog-svc-1"
  region       = "asia-southeast1"
}

resource "google_dns_record_set" "gke_syslog_svc_1_dns" {
  project = var.project

  name = "syslog.${var.top_level_domain}."
  type = "A"
  ttl  = 300
  managed_zone = "devops"

  rrdatas = [google_compute_address.gke_syslog_svc_1.address]
}
