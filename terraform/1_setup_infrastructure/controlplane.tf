
resource "random_string" "token_part_1" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_part_2" {
  length  = 16
  special = false
  upper   = false
}


data "template_file" "controlplane_init" {
  template = "${file("${path.module}/scripts/controlplane_init.sh")}"
  vars = {
    kubeadm_token     = "${random_string.token_part_1.result}.${random_string.token_part_2.result}"
    config_bucket_url = google_storage_bucket.config_bucket.url
   }
}

resource "google_compute_instance" "k8s_controlplane" {
  name         = "k8s-controlplane"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      size  = "30"
      type  = "pd-standard"
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network    = google_compute_network.compute-network.id
    subnetwork = var.subnetwork_name
    access_config {

    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "akshay:${file("~/.ssh/gcp_id.pub")}"
  }

  metadata_startup_script = data.template_file.controlplane_init.rendered
  depends_on = [
    google_compute_subnetwork.compute-subnetwork,
  ]
}
