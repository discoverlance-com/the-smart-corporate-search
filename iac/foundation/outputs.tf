# VPC Outputs
output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = module.vpc.network_id
}

output "vpc_network_self_link" {
  description = "The URI of the VPC network"
  value       = module.vpc.network_self_link
}

output "vpc_subnet_id" {
  description = "The ID of the main subnet"
  value       = module.vpc.subnets["main"].id
}

output "vpc_subnet_self_link" {
  description = "The URI of the main subnet"
  value       = module.vpc.subnets["main"].self_link
}

# Service Account Outputs
output "frontend_service_account_email" {
  description = "Email of the frontend service account"
  value       = module.frontend_service_account.service_account_email
}

output "ai_agent_service_account_email" {
  description = "Email of the AI agent service account"
  value       = module.ai_agent_service_account.service_account_email
}

output "mcp_toolbox_service_account_email" {
  description = "Email of the MCP toolbox service account"
  value       = module.mcp_toolbox_service_account.service_account_email
}

# Cloud SQL Outputs
output "cloud_sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = module.cloud_sql.instance_name
}

output "cloud_sql_instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = module.cloud_sql.connection_name
}

output "cloud_sql_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.cloud_sql.private_ip_address
}

output "cloud_sql_database_name" {
  description = "Name of the main database"
  value       = var.cloud_sql_database_name
}

# Artifact Registry Outputs
output "artifact_registry_repository_url" {
  description = "URL of the artifact registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}"
}

# Project Configuration
output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

# Google API Key Secret
output "google_api_key_secret_id" {
  description = "The ID of the Google API Key secret"
  value       = module.google_api_key_secret.secret_ids["google_api_key"]
}

# MCP Tools Config Secret
output "mcp_tools_config_secret_id" {
  description = "The ID of the MCP tools config secret"
  value       = module.google_api_key_secret.secret_ids["mcp_tools_config"]
}
