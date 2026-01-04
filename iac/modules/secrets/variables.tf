variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "region" {
  description = "The GCP region for secret replication"
  type        = string
  default     = "us-central1"
}

variable "secrets" {
  description = "Map of secrets to create with their configurations"
  type = map(object({
    secret_id           = string
    labels              = optional(map(string), {})
    deletion_protection = optional(bool, true)
    accessor_members    = optional(list(string), [])
  }))
  validation {
    condition = alltrue([
      for secret_key, secret in var.secrets : length(secret.secret_id) > 0 && length(secret.secret_id) <= 255
    ])
    error_message = "Secret IDs must be between 1 and 255 characters."
  }
  validation {
    condition = alltrue([
      for secret_key, secret in var.secrets : can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]*$", secret.secret_id))
    ])
    error_message = "Secret IDs must start with a letter or digit and can only contain letters, digits, hyphens, and underscores."
  }
}

variable "default_labels" {
  description = "Default labels to apply to all secrets"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for k, v in var.default_labels : can(regex("^[\\p{Ll}\\p{Lo}][\\p{Ll}\\p{Lo}\\p{N}_-]{0,62}$", k))
    ])
    error_message = "Label keys must start with a lowercase letter and be 1-63 characters long."
  }
  validation {
    condition = alltrue([
      for k, v in var.default_labels : can(regex("^[\\p{Ll}\\p{Lo}\\p{N}_-]{0,63}$", v))
    ])
    error_message = "Label values must be 0-63 characters long with allowed characters."
  }
}
