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

# VPC Variables
variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "corporate-search-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "corporate-search-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Service Account Variables
variable "frontend_service_account_id" {
  description = "Service account ID for frontend service"
  type        = string
  default     = "corporate-agent-frontend-svc"
}

variable "ai_agent_service_account_id" {
  description = "Service account ID for AI agent service"
  type        = string
  default     = "corporate-agent-ai-agent-svc"
}

variable "mcp_toolbox_service_account_id" {
  description = "Service account ID for MCP toolbox service"
  type        = string
  default     = "corporate-agent-mcp-svc"
}

# Artifact Registry Variables
variable "artifact_registry_name" {
  description = "Name of the artifact registry repository"
  type        = string
  default     = "smart-corporate-search"
}

# Cloud SQL Variables
variable "cloud_sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "corporate-search-db"
}

variable "cloud_sql_database_name" {
  description = "Name of the database"
  type        = string
  default     = "corporate_data"
}
