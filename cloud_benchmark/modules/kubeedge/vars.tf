variable "config_bucket" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "edge_node_count" {
  type = number
  description = "The number of kubeedge edge core nodes to deploy"
}

# variable "pvt_key" {
#   type = string
#   description = "Path to private key"
# }

variable "cloudcore_machine_type" {
  type = string
  description = "Google CLoud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"

}

variable "edgecore_machine_type" {
  type = string
  description = "Google CLoud Machine Type. More information at https://cloud.google.com/compute/docs/machine-types"
}