data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

data "template_file" "cloudcore_init" {
  template = "${file("${path.module}/scripts/cloudcore_init.sh")}"
  vars = {
    config_bucket_url = var.config_bucket
  }
}

data "template_file" "edgecore_init" {
  template = "${file("${path.module}/scripts/edgecore_init.sh")}"
  vars = {
    config_bucket_url = var.config_bucket
  }
}

resource "google_compute_instance" "kubeedge_cloudcore" {
  name         = "kubeedge-cloudcore"
  machine_type = var.cloudcore_machine_type
  zone         = var.zone
  tags         = ["cloudcore"]
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
    enable-oslogin = "TRUE"
    ssh-keys       = "akshay:${file("~/.ssh/id_rsa.pub")}"
    user-data      = <<EOT
#cloud-config
packages: ["ansible"]
write_files:
- path: /etc/ansible/ansible.cfg
  content: |
      [defaults]
      remote_tmp     = /tmp
      local_tmp      = /tmp
      host_key_checking = no
      ansible_python_interpreter = /usr/bin/python3
EOT
  }
  metadata_startup_script = data.template_file.cloudcore_init.rendered
}

resource "google_compute_instance" "kubeedge_edgecore" {
  count        = var.edge_node_count
  name         = "kubeedge-edgecore-${count.index}"
  machine_type = var.edgecore_machine_type
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
      # This is required to add an external IP address which is then used to contact the config bucket
      # Without it, the compute instance does not have internet access.
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys = "akshay:${file("~/.ssh/id_rsa.pub")}"
    user-data      = <<EOT
#edge-config
packages: ["ansible"]
write_files:
- path: /etc/ansible/ansible.cfg
  content: |
      [defaults]
      remote_tmp     = /tmp
      local_tmp      = /tmp
      host_key_checking = no
      ansible_python_interpreter = /usr/bin/python3
EOT
  }
  metadata_startup_script = data.template_file.edgecore_init.rendered
}