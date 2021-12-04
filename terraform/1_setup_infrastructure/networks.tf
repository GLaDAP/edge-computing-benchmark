resource "google_compute_subnetwork" "compute-subnetwork" {
  name          = var.subnetwork_name
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.compute-network.id
}

resource "google_compute_network" "compute-network" {
  name                    = "test-network"
  auto_create_subnetworks = false
}
