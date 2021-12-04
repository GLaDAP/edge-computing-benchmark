variable "vpc_name" {
  type = string
}

variable "region" {
  type = string
}

variable "subnetwork_name" {
    type = string
}

variable "zone" {
  type = string
}

variable "edge_node_count" {
  type = number
}

variable "project_name" {
    type = string
}

variable "ip_cidr_range" {
    type = string
}

variable "credentials_file_location" {
    type = string
}
