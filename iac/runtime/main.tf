data "terraform_remote_state" "foundation" {
  backend = "gcs"

  config = {
    bucket = "omni-deploy-run-demo-bucket"
    prefix = "the-smart-corporate-search-terraform-state/foundation/terraform/state" # reference the foundation state
  }
}

module "frontend_service" {
  source = "../modules/cloud_run"

  project_id   = var.project_id
  region       = var.region
  service_name = "frontend"

  # Container Configuration
  containers = [{
    image = var.frontend_container_image
    env = [
      {
        name  = "AI_AGENT_URL"
        value = module.ai_agent_service.service_uri
      },
    ]
    ports = [{
      container_port = 8501
    }]
    resources = {
      limits = {
        cpu    = "1000m"
        memory = "512Mi"
      }
    }
  }]

  scaling = {
    max_instance_count = 2
    min_instance_count = 0
  }

  traffic = [{
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }]

  service_account = data.terraform_remote_state.foundation.outputs.frontend_service_account_email

  ingress              = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled = true

  vpc_access = {
    egress = "ALL_TRAFFIC"
    network_interfaces = [{
      subnetwork = data.terraform_remote_state.foundation.outputs.vpc_subnet_id
    }]
  }

  deletion_protection = false # enable delete protection in production

  # Labels
  labels = {
    service = "frontend"
    env     = "runtime"
  }
}

module "ai_agent_service" {
  source = "../modules/cloud_run"

  project_id   = var.project_id
  region       = var.region
  service_name = "ai-agent"

  # Container Configuration
  containers = [{
    image = var.ai_agent_container_image
    env = [
      {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      },
      {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = var.region
      },
      {
        name  = "GOOGLE_GENAI_USE_VERTEXAI"
        value = "False"
      },
      {
        name  = "ENABLE_CLOUD_TRACE"
        value = "True"
      },
      {
        name  = "GEMINI_QUERY_ANALYST_MODEL_NAME"
        value = "gemini-2.5-pro"
      },
      {
        name  = "GEMINI_PRESENTER_MODEL_NAME"
        value = "gemini-2.5-flash"
      },
      {
        name  = "COMPANY_NAME"
        value = "TechCorp"
      },
      {
        name  = "MCP_TOOLBOX_SERVICE_URL"
        value = module.mcp_toolbox_service.service_uri
      },
      {
        name = "GOOGLE_API_KEY"
        value_source = {
          secret_key_ref = {
            secret  = data.terraform_remote_state.foundation.outputs.google_api_key_secret_id
            version = "latest"
          }
        }
      },
      {
        name  = "ENVIRONMENT"
        value = "runtime"
      }
    ]
    ports = [{
      container_port = 8080
    }]
    resources = {
      limits = {
        cpu    = "2000m"
        memory = "2Gi"
      }
    }
  }]

  scaling = {
    max_instance_count = 2
    min_instance_count = 0
  }

  traffic = [{
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }]

  service_account = data.terraform_remote_state.foundation.outputs.ai_agent_service_account_email

  ingress         = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  invoker_members = ["serviceAccount:${data.terraform_remote_state.foundation.outputs.frontend_service_account_email}"]

  vpc_access = {
    egress = "ALL_TRAFFIC"
    network_interfaces = [{
      subnetwork = data.terraform_remote_state.foundation.outputs.vpc_subnet_id
    }]
  }

  deletion_protection = false

  labels = {
    service = "ai-agent"
    env     = "runtime"
  }
}

module "mcp_toolbox_service" {
  source = "../modules/cloud_run"

  project_id   = var.project_id
  region       = var.region
  service_name = "mcp-toolbox"

  containers = [{
    image = var.mcp_toolbox_container_image
    args = [
      "--tools-file=/app/tools.yaml",
      "--address=0.0.0.0",
      "--port=8081",
      "--telemetry-gcp"
    ]
    env = [
      {
        name  = "DB_PROJECT"
        value = var.project_id
      },
      {
        name  = "DB_REGION"
        value = var.region
      },
      {
        name  = "DB_INSTANCE"
        value = data.terraform_remote_state.foundation.outputs.cloud_sql_instance_name
      },
      {
        name  = "DB_HOST"
        value = data.terraform_remote_state.foundation.outputs.cloud_sql_private_ip
      },
      {
        name  = "DB_NAME"
        value = data.terraform_remote_state.foundation.outputs.cloud_sql_database_name
      },
      {
        name  = "DB_USER"
        value = replace(data.terraform_remote_state.foundation.outputs.mcp_toolbox_service_account_email, ".gserviceaccount.com", "")
      },
      {
        name  = "ENVIRONMENT"
        value = "runtime"
      },
      {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
    ]
    ports = [{
      container_port = 8081
    }]
    volume_mounts = [{
      name       = "tools-config"
      mount_path = "/app"
    }]
    resources = {
      limits = {
        cpu    = "1000m"
        memory = "1Gi"
      }
    }
  }]

  volumes = [{
    name = "tools-config"
    secret = {
      secret = data.terraform_remote_state.foundation.outputs.mcp_tools_config_secret_id
      items = [{
        path = "tools.yaml"
      }]
    }
  }]

  scaling = {
    max_instance_count = 10
    min_instance_count = 0
  }

  traffic = [{
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }]

  service_account = data.terraform_remote_state.foundation.outputs.mcp_toolbox_service_account_email

  vpc_access = {
    egress = "ALL_TRAFFIC"
    network_interfaces = [{
      subnetwork = data.terraform_remote_state.foundation.outputs.vpc_subnet_id
    }]
  }
  deletion_protection = false

  ingress         = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  invoker_members = ["serviceAccount:${data.terraform_remote_state.foundation.outputs.ai_agent_service_account_email}"]

  labels = {
    service = "mcp-toolbox"
    env     = "runtime"
  }
}
