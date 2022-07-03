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
