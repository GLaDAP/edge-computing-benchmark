variable "region" {
  type = string
  description = "Name of the Google Cloud region to deploy (https://cloud.google.com/compute/docs/regions-zones)"
}

variable "vpc_name" {
  type = string
  description = "Name of the Google Compute Network"
}

variable "zone" {
  type = string
  description = "Name of the zone within the region to deploy (https://cloud.google.com/compute/docs/regions-zones)"
}

variable "project_name" {
  type = string
  description = "The name of the Google Cloud project"
}

variable "edge_node_count" {
  type = number
  description = "Number of Kubeedge edgecore nodes to deploy"
}

variable "credentials_file_location" {
  type = string
  description = "Location of the JSON file containing the credentials of the service account."
}

variable "gcp_storage_location" {
  type = string
  description = "Location of the configuration bucket"
}

variable "cloudcore_machine_type" {
  type = string
  description = "Google CLoud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"
}

variable "edgecore_machine_type" {
  type = string
  description = "Google Cloud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"
}

variable "subnetwork_name" {
  type = string
  description = "The name of the Google Cloud subnetwork"
}