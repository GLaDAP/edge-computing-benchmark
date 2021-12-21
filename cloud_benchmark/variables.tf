variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "project_name" {
  type = string
}

variable "edge_node_count" {
  type = number
}

variable "credentials_file_location" {
  type = string
}

variable "gcp_storage_location" {
  type = string
  description = "Location of the configuration bucket"
  default = "US-CENTRAL1"
}

variable "cloudcore_machine_type" {
  type = string
  description = "Google CLoud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"
}

variable "edgecore_machine_type" {
  type = string
  description = "Google CLoud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"
}


variable "subnetwork_name" {
  type = string
}