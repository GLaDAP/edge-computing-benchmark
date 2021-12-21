provider "google" {
  credentials = file(var.credentials_file_location)
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_name = var.vpc_name
  region   = var.region
  subnetwork_name = var.subnetwork_name
}

module "kubeedge" {
  source                 = "./modules/kubeedge"
  config_bucket          = google_storage_bucket.config_bucket.url
  vpc_name               = var.vpc_name
  zone                   = var.zone
  subnetwork_name        = module.vpc.subnetwork_1_name
  edge_node_count        = var.edge_node_count
  cloudcore_machine_type = var.cloudcore_machine_type
  edgecore_machine_type  = var.edgecore_machine_type
}

