# Frontend Service Outputs
output "frontend_service_url" {
  description = "The URL of the frontend service"
  value       = module.frontend_service.service_uri
}

output "frontend_service_name" {
  description = "The name of the frontend service"
  value       = module.frontend_service.service_name
}

# AI Agent Service Outputs
output "ai_agent_service_url" {
  description = "The URL of the AI agent service"
  value       = module.ai_agent_service.service_uri
}

output "ai_agent_service_name" {
  description = "The name of the AI agent service"
  value       = module.ai_agent_service.service_name
}

# MCP Toolbox Service Outputs
output "mcp_toolbox_service_url" {
  description = "The URL of the MCP toolbox service"
  value       = module.mcp_toolbox_service.service_uri
}

output "mcp_toolbox_service_name" {
  description = "The name of the MCP toolbox service"
  value       = module.mcp_toolbox_service.service_name
}

# Service URLs for reference
output "service_urls" {
  description = "Map of all service URLs"
  value = {
    frontend    = module.frontend_service.service_uri
    ai_agent    = module.ai_agent_service.service_uri
    mcp_toolbox = module.mcp_toolbox_service.service_uri
  }
}

# Foundation Data
output "foundation_outputs" {
  description = "All foundation outputs for reference"
  value = {
    project_id              = var.project_id
    region                  = var.region
    vpc_network_id          = data.terraform_remote_state.foundation.outputs.vpc_network_id
    cloud_sql_instance_name = data.terraform_remote_state.foundation.outputs.cloud_sql_instance_name
    artifact_registry_url   = data.terraform_remote_state.foundation.outputs.artifact_registry_repository_url
  }
}
