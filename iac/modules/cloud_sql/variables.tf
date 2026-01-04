variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "region" {
  description = "The region where the SQL instance will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9-]+[0-9]$", var.region))
    error_message = "Region must be a valid Google Cloud region format (e.g., us-central1)."
  }
}

variable "instance_name" {
  description = "The name of the SQL instance"
  type        = string
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.instance_name)) && length(var.instance_name) <= 98
    error_message = "Instance name must be 1-98 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "database_version" {
  description = "The database version (e.g., POSTGRES_15, MYSQL_8_0)"
  type        = string
  validation {
    condition = contains([
      "POSTGRES_9_6", "POSTGRES_10", "POSTGRES_11", "POSTGRES_12", "POSTGRES_13", "POSTGRES_14", "POSTGRES_15", "POSTGRES_16", "POSTGRES_17",
      "MYSQL_5_6", "MYSQL_5_7", "MYSQL_8_0", "MYSQL_8_4",
      "SQLSERVER_2017_STANDARD", "SQLSERVER_2017_ENTERPRISE", "SQLSERVER_2017_EXPRESS", "SQLSERVER_2017_WEB",
      "SQLSERVER_2019_STANDARD", "SQLSERVER_2019_ENTERPRISE", "SQLSERVER_2019_EXPRESS", "SQLSERVER_2019_WEB"
    ], var.database_version)
    error_message = "Database version must be a supported Google Cloud SQL version."
  }
}

variable "tier" {
  description = "The machine type tier for the SQL instance"
  type        = string
  default     = "db-f1-micro"
  validation {
    condition     = can(regex("^db-(f1-micro|g1-small|n1-|custom-|perf-optimized-)", var.tier))
    error_message = "Tier must be a valid Cloud SQL machine type."
  }
}

variable "edition" {
  description = "The edition of the instance (ENTERPRISE or ENTERPRISE_PLUS)"
  type        = string
  default     = "ENTERPRISE"
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "Edition must be either ENTERPRISE or ENTERPRISE_PLUS."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the instance"
  type        = bool
  default     = true
}

# Network configuration
variable "private_network" {
  description = "The VPC network from which the Cloud SQL instance is accessible for private IP"
  type        = string
}

variable "ipv4_enabled" {
  description = "Whether to enable IPv4 on the instance"
  type        = bool
  default     = false
}

variable "allocated_ip_range" {
  description = "The name of the allocated IP range for the private IP CloudSQL instance"
  type        = string
  default     = null
}

variable "enable_private_path_for_google_cloud_services" {
  description = "Whether to enable private path for Google Cloud services"
  type        = bool
  default     = true
}

variable "ssl_mode" {
  description = "SSL connection enforcement mode"
  type        = string
  default     = "ENCRYPTED_ONLY"
  validation {
    condition = contains([
      "ALLOW_UNENCRYPTED_AND_ENCRYPTED",
      "ENCRYPTED_ONLY",
      "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    ], var.ssl_mode)
    error_message = "SSL mode must be a valid option."
  }
}

variable "authorized_networks" {
  description = "List of authorized networks for public access"
  type = list(object({
    name            = string
    value           = string
    expiration_time = optional(string)
  }))
  default = []
}

# Storage configuration
variable "availability_type" {
  description = "The availability type (REGIONAL for HA, ZONAL for single zone)"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.availability_type)
    error_message = "Availability type must be either REGIONAL or ZONAL."
  }
}

variable "disk_size" {
  description = "The disk size in GB"
  type        = number
  default     = 10
  validation {
    condition     = var.disk_size >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "disk_type" {
  description = "The disk type (PD_SSD, PD_HDD, or HYPERDISK_BALANCED)"
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD", "HYPERDISK_BALANCED"], var.disk_type)
    error_message = "Disk type must be PD_SSD, PD_HDD, or HYPERDISK_BALANCED."
  }
}

variable "disk_autoresize" {
  description = "Whether to enable automatic storage size increases"
  type        = bool
  default     = false
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto-resized (0 = no limit)"
  type        = number
  default     = 0
}

# Labels and flags
variable "user_labels" {
  description = "User labels to apply to the instance"
  type        = map(string)
  default     = {}
}

# Databases and IAM users
variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    name      = string
    charset   = optional(string)
    collation = optional(string)
  }))
  default = {}
}

variable "iam_users" {
  description = "List of IAM members (service accounts) to grant Cloud SQL Instance User access"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for member in var.iam_users :
      can(regex("^(user:|serviceAccount:|group:|domain:)", member))
    ])
    error_message = "IAM users must be valid IAM member identifiers (e.g., serviceAccount:my-sa@project.iam.gserviceaccount.com)."
  }
}
