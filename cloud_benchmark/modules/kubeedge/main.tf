data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
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
runcmd:
- gsutil cp -r ${var.config_bucket}/ansible /opt
- ansible-playbook /opt/ansible/cloud_playbook.yml --extra-vars "bucket_url=${var.config_bucket}"
EOT
  }
}

#ansible-playbook /opt/ansible/controller_startup.yml --extra-vars "bucket_url=gs://edge-benchmark-config-bucket"

# - ansible-playbook /opt/ansible/base_install.yml
# - sh /opt/ansible/script/prepare_cloudcore.sh

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
runcmd:
- gsutil cp -r ${var.config_bucket}/ansible /opt
- ansible-playbook /opt/ansible/edge_playbook.yml --extra-vars "bucket_url=${var.config_bucket}"
EOT
  }
}
# gsutil cp -r gs://edge-benchmark-config-bucket/ansible /opt
# 
# ansible-playbook /opt/ansible/edge_playbook.yml --extra-vars "bucket_url=gs://edge-benchmark-config-bucket"