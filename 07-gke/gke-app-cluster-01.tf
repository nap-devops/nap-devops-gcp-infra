locals {
  region = "asia-southeast1-b"

  cluster_name = "devops-apps"
  network_name = var.vpc_name
  kubernetes_version_1 = "1.24.5-gke.600"
  nodes_subnetwork_name = "gke-asia-southeast1-001"
  pods_secondary_ip_range_name = "devops-gke-pods"
  services_secondary_ip_range_name = "devops-gke-svc"
  master_ipv4_cidr_block = "10.255.0.0/28" #Need to create dedicate subnet for GKE master
}

#### Service Account ####
resource "google_service_account" "gke-cluster-sa" {
  account_id   = "devops-gke-app"
  display_name = "Service Account for GKE cluster"
}

resource "google_project_iam_member" "gke_storage_admin" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gke-cluster-sa.email}"
}

resource "google_project_iam_member" "gke_secretmanager_admin" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.gke-cluster-sa.email}"
}

#### Cluster ####
module "gke-cluster" {
  source = "git::https://github.com/its-software-services-devops/tf-module-gke.git//modules?ref=1.0.3"

  name                             = local.cluster_name
  project                          = var.project
  region                           = local.region
  kubernetes_version               = local.kubernetes_version_1
  network_name                     = local.network_name
  nodes_subnetwork_name            = local.nodes_subnetwork_name
  pods_secondary_ip_range_name     = local.pods_secondary_ip_range_name
  services_secondary_ip_range_name = local.services_secondary_ip_range_name
  enable_shielded_nodes            = true

  # private cluster options
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = local.master_ipv4_cidr_block

  # GKE metering
  #enable_network_egress_metering = false
  #metering_bigquery_dataset = "gke_metering"
  
  # Workload Identity
  enable_workload_identity = true
  # GKE backup
  enable_gke_backup = true

  master_authorized_network_cidrs = [
    {
      # This is the module default, but demonstrates specifying this input.
      cidr_block   = "0.0.0.0/0"
      display_name = "From the internet"
    },
  ]
}

#### Pools ####

module "gke-cluster-pool1" {
  source = "git::https://github.com/its-software-services-devops/tf-module-gke-nodepool.git//modules?ref=1.0.3"

  name             = "${local.cluster_name}-pool1"
  region           = local.region
  gke_cluster_name = "${local.cluster_name}"
  machine_type     = var.gke_machine_type
  min_node_count   = var.gke_min_node_count
  max_node_count   = var.gke_max_node_count
  node_count       = var.gke_node_count
  service_account_email = google_service_account.gke-cluster-sa.email

  node_metadata = "GKE_METADATA"
  image_type = "COS_CONTAINERD"

  # Match the Kubernetes version from the GKE cluster!
  kubernetes_version = local.kubernetes_version_1
}
