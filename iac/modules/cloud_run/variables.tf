variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID cannot be empty."
  }
}

variable "region" {
  description = "The region where the Cloud Run service will be deployed"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9-]+[0-9]$", var.region))
    error_message = "Region must be a valid Google Cloud region format (e.g., us-central1)."
  }
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.service_name)) && length(var.service_name) <= 63
    error_message = "Service name must be 1-63 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "description" {
  description = "Description of the Cloud Run service"
  type        = string
  default     = ""
  validation {
    condition     = length(var.description) <= 512
    error_message = "Description must be 512 characters or less."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the service"
  type        = bool
  default     = true
}

variable "ingress" {
  description = "Ingress settings for the service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    ], var.ingress)
    error_message = "Ingress must be a valid option."
  }
}

variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the service"
  type        = map(string)
  default     = {}
}

variable "template_labels" {
  description = "Labels to apply to the revision template"
  type        = map(string)
  default     = {}
}

variable "template_annotations" {
  description = "Annotations to apply to the revision template"
  type        = map(string)
  default     = {}
}

# Service account configuration
variable "service_account" {
  description = "Service account email to run the service as"
  type        = string
  default     = null
  validation {
    condition     = var.service_account == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.service_account))
    error_message = "Service account must be a valid email address."
  }
}

# Scaling configuration
variable "scaling" {
  description = "Service-level scaling configuration"
  type = object({
    min_instance_count    = optional(number)
    max_instance_count    = optional(number)
    scaling_mode          = optional(string, "AUTOMATIC")
    manual_instance_count = optional(number)
  })
  default = null
  validation {
    condition = var.scaling == null || (
      var.scaling.scaling_mode == null ||
      contains(["AUTOMATIC", "MANUAL"], var.scaling.scaling_mode)
    )
    error_message = "Scaling mode must be AUTOMATIC or MANUAL."
  }
}

variable "template_scaling" {
  description = "Template-level scaling configuration"
  type = object({
    min_instance_count = optional(number)
    max_instance_count = optional(number)
  })
  default = null
}

# Template configuration
variable "timeout" {
  description = "Maximum allowed time for an instance to respond to a request"
  type        = string
  default     = "300s"
  validation {
    condition     = can(regex("^[0-9]+s$", var.timeout))
    error_message = "Timeout must be in seconds format (e.g., '300s')."
  }
}

variable "execution_environment" {
  description = "The execution environment for the service"
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
  validation {
    condition = contains([
      "EXECUTION_ENVIRONMENT_GEN1",
      "EXECUTION_ENVIRONMENT_GEN2"
    ], var.execution_environment)
    error_message = "Execution environment must be GEN1 or GEN2."
  }
}

variable "max_instance_request_concurrency" {
  description = "Maximum number of requests that each serving instance can receive"
  type        = number
  default     = null
  validation {
    condition     = var.max_instance_request_concurrency == null || var.max_instance_request_concurrency > 0
    error_message = "Max instance request concurrency must be greater than 0."
  }
}

variable "session_affinity" {
  description = "Enable session affinity for the service"
  type        = bool
  default     = false
}

variable "health_check_disabled" {
  description = "Disable health checking containers during deployment"
  type        = bool
  default     = false
}

# VPC access configuration
variable "vpc_access" {
  description = "VPC access configuration"
  type = object({
    connector = optional(string)
    egress    = optional(string, "PRIVATE_RANGES_ONLY")
    network_interfaces = optional(list(object({
      network    = optional(string)
      subnetwork = optional(string)
      tags       = optional(list(string))
    })))
  })
  default = null
  validation {
    condition = var.vpc_access == null || (
      var.vpc_access.egress == null ||
      contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_access.egress)
    )
    error_message = "VPC egress must be ALL_TRAFFIC or PRIVATE_RANGES_ONLY."
  }
}

# Container configuration
variable "containers" {
  description = "Container configurations for the service"
  type = list(object({
    name        = optional(string)
    image       = string
    command     = optional(list(string))
    args        = optional(list(string))
    working_dir = optional(string)
    depends_on  = optional(list(string))
    env = optional(list(object({
      name  = string
      value = optional(string)
      value_source = optional(object({
        secret_key_ref = optional(object({
          secret  = string
          version = optional(string, "latest")
        }))
      }))
    })))
    resources = optional(object({
      limits            = optional(map(string))
      cpu_idle          = optional(bool)
      startup_cpu_boost = optional(bool)
    }))
    ports = optional(list(object({
      name           = optional(string)
      container_port = number
    })))
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      sub_path   = optional(string)
    })))
    liveness_probe = optional(object({
      initial_delay_seconds = optional(number, 0)
      timeout_seconds       = optional(number, 1)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
      http_get = optional(object({
        path = optional(string, "/")
        port = optional(number)
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
      }))
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      tcp_socket = optional(object({
        port = number
      }))
    }))
    startup_probe = optional(object({
      initial_delay_seconds = optional(number, 0)
      timeout_seconds       = optional(number, 1)
      period_seconds        = optional(number, 3)
      failure_threshold     = optional(number, 1)
      http_get = optional(object({
        path = optional(string, "/")
        port = optional(number)
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
      }))
      grpc = optional(object({
        port    = optional(number)
        service = optional(string)
      }))
      tcp_socket = optional(object({
        port = number
      }))
    }))
  }))
  validation {
    condition     = length(var.containers) > 0
    error_message = "At least one container must be specified."
  }
}

# Volume configuration
variable "volumes" {
  description = "Volumes to attach to containers"
  type = list(object({
    name = string
    secret = optional(object({
      secret       = string
      default_mode = optional(number)
      items = optional(list(object({
        path    = string
        version = optional(string, "latest")
        mode    = optional(number)
      })))
    }))
    cloud_sql_instance = optional(object({
      instances = list(string)
    }))
    empty_dir = optional(object({
      medium     = optional(string, "MEMORY")
      size_limit = optional(string)
    }))
  }))
  default = []
}

# Traffic configuration
variable "traffic" {
  description = "Traffic allocation configuration"
  type = list(object({
    type     = optional(string, "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST")
    revision = optional(string)
    percent  = optional(number, 100)
    tag      = optional(string)
  }))
  default = null
  validation {
    condition = var.traffic == null || alltrue([
      for t in var.traffic : contains([
        "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
        "TRAFFIC_TARGET_ALLOCATION_TYPE_REVISION"
      ], t.type)
    ])
    error_message = "Traffic type must be LATEST or REVISION."
  }
}

# IAM configuration
variable "invoker_members" {
  description = "List of members who can invoke the Cloud Run service"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for member in var.invoker_members :
      can(regex("^(user:|serviceAccount:|group:|domain:|allUsers|allAuthenticatedUsers)", member))
    ])
    error_message = "Invoker members must be valid IAM member identifiers."
  }
}

variable "invoker_iam_disabled" {
  description = "Whether to disable IAM authentication for the service (allows unauthenticated access)"
  type        = bool
  default     = false
}
