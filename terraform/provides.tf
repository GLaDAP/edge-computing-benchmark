terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6.1"
    }
    google = {
        source = "hashicorp/google"
        version = "~> 4.2.0"
    }
  }
}
