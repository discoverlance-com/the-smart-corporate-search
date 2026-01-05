module "enable_apis" {
  source     = "../modules/apis"
  project_id = var.project_id
  apis = [
    "run.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudtrace.googleapis.com"
  ]
}

module "vpc" {
  source = "../modules/vpc"

  project_id   = var.project_id
  network_name = var.vpc_name
  description  = "VPC network for Corporate Search application"

  subnets = {
    main = {
      name                     = var.subnet_name
      ip_cidr_range            = var.subnet_cidr
      region                   = var.region
      description              = "Subnet for Corporate Search services"
      private_ip_google_access = true
    }
  }

  depends_on = [module.enable_apis]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "psa-cloudsql-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_id
  project       = var.project_id

  depends_on = [module.vpc]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  deletion_policy = "ABANDON"

  depends_on = [google_compute_global_address.private_ip_address]
}

module "frontend_service_account" {
  source       = "../modules/service_accounts"
  account_id   = var.frontend_service_account_id
  display_name = "Corporate Agent Frontend Service Account"
  project_id   = var.project_id

  roles = [
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/monitoring.metricWriter"
  ]

  depends_on = [module.enable_apis]
}

module "ai_agent_service_account" {
  source       = "../modules/service_accounts"
  account_id   = var.ai_agent_service_account_id
  display_name = "Corporate Agent AI Agent Service Account"
  project_id   = var.project_id

  roles = [
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/monitoring.metricWriter"
  ]

  depends_on = [module.enable_apis]
}

module "mcp_toolbox_service_account" {
  source       = "../modules/service_accounts"
  account_id   = var.mcp_toolbox_service_account_id
  display_name = "Corporate Agent MCP Toolbox Service Account"
  project_id   = var.project_id

  roles = [
    "roles/logging.logWriter",
    "roles/cloudtrace.agent",
    "roles/monitoring.metricWriter"
  ]

  depends_on = [module.enable_apis]
}

resource "google_artifact_registry_repository" "app_repo" {
  repository_id = var.artifact_registry_name
  location      = var.region
  description   = "Docker repository for smart corporate search application"
  format        = "DOCKER"
  project       = var.project_id

  docker_config {
    immutable_tags = false
  }

  depends_on = [module.enable_apis]
}

module "cloud_sql" {
  source = "../modules/cloud_sql"

  project_id          = var.project_id
  region              = var.region
  instance_name       = var.cloud_sql_instance_name
  database_version    = "POSTGRES_17"
  tier                = "db-g1-small"
  deletion_protection = false

  private_network = module.vpc.network_self_link
  ipv4_enabled    = false

  databases = {
    main = {
      name = var.cloud_sql_database_name
    }
  }

  iam_users = [
    "serviceAccount:${module.mcp_toolbox_service_account.service_account_email}"
  ]

  depends_on = [module.enable_apis, module.vpc, google_service_networking_connection.private_vpc_connection]
}

module "google_api_key_secret" {
  source = "../modules/secrets"

  project_id = var.project_id
  region     = "us-central1"

  secrets = {
    google_api_key = {
      secret_id           = "google-api-key"
      deletion_protection = false
      labels = {
        service = "ai-agent"
        env     = "foundation"
      }
      accessor_members = [
        "serviceAccount:${module.ai_agent_service_account.service_account_email}"
      ]
    }
    mcp_tools_config = {
      secret_id           = "mcp-tools-config"
      deletion_protection = false
      labels = {
        service = "mcp-toolbox"
        env     = "foundation"
      }
      accessor_members = [
        "serviceAccount:${module.mcp_toolbox_service_account.service_account_email}"
      ]
    }
  }

  default_labels = {
    managed_by = "terraform"
    env        = "foundation"
  }

  depends_on = [module.enable_apis, module.ai_agent_service_account]
}

