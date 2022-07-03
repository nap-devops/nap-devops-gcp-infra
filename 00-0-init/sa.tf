
#GKE External Secret, Cortex & Loki
resource "google_service_account" "gke_internal_service_account" {
  account_id   = "gke-devops-sa"
  display_name = "Terraform - GCE service account for GKE"
}

resource "google_project_iam_member" "gke_internal_storage_admin" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gke_internal_service_account.email}"
}

resource "google_project_iam_member" "gke_internal_sm_admin" {
  project = var.project
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.gke_internal_service_account.email}"
}

resource "google_project_iam_member" "gke_internal_dns_admin" {
  project = var.project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.gke_internal_service_account.email}"
}
