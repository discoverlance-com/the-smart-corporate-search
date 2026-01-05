terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.14.1"
    }
  }
  backend "gcs" {
    bucket = "omni-deploy-run-demo-bucket"
    prefix = "the-smart-corporate-search-terraform-state/runtime/terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
