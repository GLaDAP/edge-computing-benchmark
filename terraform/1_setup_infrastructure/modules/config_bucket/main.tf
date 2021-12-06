resource "google_storage_bucket" "config_bucket" {
  name          = "${var.project_name}-config-bucket-1"
  force_destroy = true
  location = "US-CENTRAL1"
}