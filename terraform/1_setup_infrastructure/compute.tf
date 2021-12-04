provider "google" {
  credentials = file(var.credentials_file_location)
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "kubeedge_cloudcore" {
  name         = "cloudcore"
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
    ssh-keys = "akshay:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = data.template_file.cloudcore_init.rendered
  depends_on = [
    google_compute_subnetwork.compute-subnetwork,
  ]
}

resource "google_compute_instance" "kubeedge_edgecore" {
  count        = var.edge_node_count
  name         = "edgecore-${count.index}"
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

  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "akshay:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = data.template_file.edgecore_init.rendered
  depends_on = [
    google_compute_subnetwork.compute-subnetwork,
  ]
}
