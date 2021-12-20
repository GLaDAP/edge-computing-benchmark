resource "google_storage_bucket" "config_bucket" {
  name          = "${var.project_name}-config-bucket"
  force_destroy = true
  location      = var.gcp_storage_location
}

resource "google_storage_bucket_object" "playbook" {
  for_each = fileset("${path.module}/ansible", "**")
  bucket   = google_storage_bucket.config_bucket.name
  name     = "ansible/${each.key}"
  source   = "${path.module}/ansible/${each.key}"
}
