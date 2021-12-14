data "google_compute_image" "ubuntu" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

/* Used to generate a token for kubeadm */
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


data "template_file" "cloudcore_init" {
  template = "${file("${path.module}/scripts/cloudcore_init.sh")}"
  vars = {
    kubeadm_token     = "${random_string.token_part_1.result}.${random_string.token_part_2.result}"
    config_bucket_url = var.config_bucket
  }
}

data "template_file" "edgecore_init" {
  template = "${file("${path.module}/scripts/edgecore_init.sh")}"
  vars = {
    config_bucket_url = var.config_bucket
    cloudcore_ip      = google_compute_instance.kubeedge_cloudcore.network_interface.0.access_config.0.nat_ip
  }
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
    network    = var.vpc_name
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

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install curl -y", "echo Curl Installed!"]
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = file(var.pvt_key)
    }
  }

  #metadata_startup_script = data.template_file.cloudcore_init.rendered
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
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    # access_config {

    # }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "akshay:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = data.template_file.edgecore_init.rendered
}

resource "null_resource" "download_kube_config" {
  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/download_kube_config.sh ${var.config_bucket} ${path.module}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm -f ${path.module}/output.log ${path.module}/config"
  }
}