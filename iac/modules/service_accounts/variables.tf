variable "account_id" {
  description = "The account ID that is used to generate the service account email address and a stable unique ID"
  type        = string
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.account_id)) && length(var.account_id) >= 6 && length(var.account_id) <= 30
    error_message = "Account ID must be 6-30 characters long and match the pattern [a-z]([-a-z0-9]*[a-z0-9])."
  }
}

variable "display_name" {
  description = "The display name for the service account"
  type        = string
  default     = null
}

variable "description" {
  description = "A text description of the service account"
  type        = string
  default     = null
  validation {
    condition     = var.description == null || length(var.description) <= 256
    error_message = "Description must be less than or equal to 256 UTF-8 bytes."
  }
}

variable "project_id" {
  description = "The ID of the project that the service account will be created in"
  type        = string
}

variable "disabled" {
  description = "Whether a service account is disabled or not"
  type        = bool
  default     = false
}

variable "create_ignore_already_exists" {
  description = "If set to true, skip service account creation if a service account with the same email already exists"
  type        = bool
  default     = false
}

variable "roles" {
  description = "List of roles to grant to the service account"
  type        = list(string)
  default     = []
}
