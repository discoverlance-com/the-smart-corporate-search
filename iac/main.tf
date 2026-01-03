module "enable_apis" {
  source     = "./modules/apis"
  project_id = var.project_id
  apis = [
    "run.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

module "frontend_service_account" {
  source       = "./modules/service_accounts"
  account_id   = "corporate-agent-frontend-svc"
  display_name = "Corporate Agent Frontend Service Account"
  project_id   = var.project_id

  depends_on = [module.enable_apis]
}

module "ai_agent_service_account" {
  source       = "./modules/service_accounts"
  account_id   = "corporate-agent-ai-agent-svc"
  display_name = "Corporate Agent AI Agent Service Account"
  project_id   = var.project_id

  depends_on = [module.enable_apis]
}

module "mcp_toolbox_account" {
  source       = "./modules/service_accounts"
  account_id   = "corporate-agent-mcp-svc"
  display_name = "Corporate Agent MCP Toolbox Service Account"
  project_id   = var.project_id

  depends_on = [module.enable_apis]
}

