variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.network_name)) && length(var.network_name) >= 1 && length(var.network_name) <= 63
    error_message = "Network name must be 1-63 characters long and match the pattern [a-z]([-a-z0-9]*[a-z0-9])."
  }
}

variable "description" {
  description = "An optional description of the VPC network"
  type        = string
  default     = null
}

variable "routing_mode" {
  description = "The network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Routing mode must be either REGIONAL or GLOBAL."
  }
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    name                     = string
    ip_cidr_range            = string
    region                   = string
    description              = optional(string)
    private_ip_google_access = optional(bool, true)
  }))
  default = {}
}
