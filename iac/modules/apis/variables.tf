variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "apis" {
  description = "List of Google Cloud APIs to enable"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.apis) > 0
    error_message = "At least one API must be specified."
  }
  validation {
    condition = alltrue([
      for api in var.apis : can(regex("^[a-z][a-z0-9-]*\\.googleapis\\.com$", api))
    ])
    error_message = "APIs must be in the format 'service.googleapis.com'."
  }
}

variable "disable_dependent_services" {
  description = "Whether to disable services that depend on this service when destroying"
  type        = bool
  default     = false
}

variable "disable_on_destroy" {
  description = "Whether to disable the service when the resource is destroyed"
  type        = bool
  default     = false
}
