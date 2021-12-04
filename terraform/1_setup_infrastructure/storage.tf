data "template_file" "cloudcore_init" {
  template = "${file("scripts/cloudcore_init.sh")}"
  vars = {
    config_bucket_url = google_storage_bucket.config_bucket.url
  }
}

data "template_file" "edgecore_init" {
  template = "${file("scripts/edgecore_init.sh")}"
  vars = {
    config_bucket_url = google_storage_bucket.config_bucket.url
    cloudcore_ip      = google_compute_instance.kubeedge_cloudcore.network_interface.0.access_config.0.nat_ip
  }
}

resource "google_storage_bucket" "config_bucket" {
  name          = "${var.project_name}-config-bucket"
  force_destroy = true
  location = "US-CENTRAL1"
}

resource "null_resource" "download_kube_config" {
  provisioner "local-exec" {
    command = "wsl sh $scripts/download_kube_config.sh ${google_storage_bucket.config_bucket.url} ."
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -f output.log /config"
  }
}