resource "google_compute_firewall" "icmp-inbound" {
  name    = "icmp-allow-all"
  network = var.vpc_name
  priority = 1000

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "external-lb-inbound" {
  name    = "external-lb-inbound-allow"
  network = var.vpc_name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["443", "80", "8443", "8080", "30000-40000"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}


resource "google_compute_firewall" "gke-master-inbound" {
  name    = "gke-master-inbound-allow"
  network = var.vpc_name
  priority = 1000

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.255.0.0/16"] #GKE master node put into this subnet
}

resource "google_compute_firewall" "external-iap-inbound" {
  name    = "external-iap-inbound-allow"
  network = var.vpc_name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

