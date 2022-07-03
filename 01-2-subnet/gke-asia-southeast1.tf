# Put subnet in the same region into this file

resource "google_compute_subnetwork" "gke-asia-southeast1-001" {
  name          = "gke-asia-southeast1-001"
  ip_cidr_range = "10.100.1.0/24" # Make sure it is no overlaping with others
  region        = "asia-southeast1"
  network       = var.vpc_name

  secondary_ip_range {
    range_name = "devops-gke-pods"
    ip_cidr_range = "192.168.0.0/16"
  }
  
  secondary_ip_range {
    range_name = "devops-gke-svc"
    ip_cidr_range = "172.16.0.0/24"
  }

}
