variable "region" {
  description = "The region where resources will be deployed."
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

# Container Image Variables
variable "frontend_container_image" {
  description = "The frontend container image URL"
  type        = string
}

variable "ai_agent_container_image" {
  description = "The AI agent container image URL"
  type        = string
}

variable "mcp_toolbox_container_image" {
  description = "The MCP toolbox container image URL"
  type        = string
}

