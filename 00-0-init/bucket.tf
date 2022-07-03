
resource "google_storage_bucket" "bucket-loki" {
  name          = lower("${var.project}-loki")
  location      = "ASIA"
  force_destroy = true
  
  uniform_bucket_level_access = true
  storage_class = "STANDARD"
  
  versioning {
    enabled = true
  }
}
