variable "region" {
  description = "The region where resources will be deployed."
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "zone" {
  description = "The zone within the region for resource deployment."
  type        = string
  default     = "us-central1-a"
}
