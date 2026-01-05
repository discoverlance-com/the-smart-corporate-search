# The Smart Corporate Search 🤖

An intelligent internal RAG (Retrieval Augmented Generation) application that allows you to query your internal systems using natural language. Ask questions like "Who is our biggest customer by total revenue?" and get instant answers with detailed analysis, interactive charts, and actionable business insights powered by AI agents and your corporate data.

## ✨ Key Features

- **Natural Language Queries**: Ask complex business questions in plain English
- **Intelligent Analysis**: AI agents provide detailed insights and contextual analysis
- **Interactive Charts**: Automatic visualization generation for trends, comparisons, and distributions
- **Sequential Agent Architecture**: Specialized agents for data retrieval and presentation
- **Real-time Chat Interface**: Streamlit-powered frontend with persistent chat history
- **SQL Tool Integration**: MCP toolbox with comprehensive database operations

## 🏗️ Architecture

This project consists of four main components that work together to deliver intelligent corporate search capabilities:

```text
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │───▶│  AI Agent   │───▶│ MCP Toolbox │───▶│ PostgreSQL  │
│ (Streamlit) │    │  (FastAPI)  │    │   (Tools)   │    │ (Database)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Components

- **Frontend (Port 8501)**: Streamlit-based chat interface with interactive chart rendering, persistent chat history, and real-time response streaming
- **AI Agent (Port 8080)**: FastAPI application powered by Google ADK featuring sequential agent architecture with specialized retriever and presenter agents for data analysis and visualization
- **MCP Toolbox (Port 8081)**: Model Context Protocol server with comprehensive SQL tools including KPI analysis, trend analysis, customer insights, and product analytics
- **PostgreSQL (Port 5432)**: Database containing your corporate data with sample e-commerce dataset for testing and development

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Google AI API Key (Gemini)
- For cloud deployment: Google Cloud Project with billing enabled

### Setup

1. **Clone the repository**

   ```bash
   git clone git@github.com:discoverlance-com/the-smart-corporate-search.git
   cd the-smart-corporate-search
   ```

2. **Configure your Google AI API Key**

   Edit `ai-agent/corporate_agent/.env`:

   ```env
   GOOGLE_API_KEY=your_google_ai_api_key_here
   GOOGLE_GENAI_USE_VERTEXAI=0
   ```

3. **Set your Google Cloud Project (Optional)**

   ```bash
   # Option 1: Environment variable
   export GOOGLE_CLOUD_PROJECT=your-project-id

   # Option 2: Create .env file in root directory
   echo "GOOGLE_CLOUD_PROJECT=your-project-id" > .env
   ```

4. **Start all services**

   ```bash
   docker-compose up --watch
   ```

5. **Access the application**
   - Frontend: [http://localhost:8501](http://localhost:8501)
   - AI Agent API: [http://localhost:8080](http://localhost:8080)
   - MCP Toolbox: [http://localhost:8081](http://localhost:8081)

## 🛠️ Development

The project is designed for easy development with **Docker Compose watch** for instant file synchronization:

### Development Modes

#### Option 1: Docker Compose Watch (Recommended)

```bash
# Start all services with live file watching
docker-compose up --watch

# Or start services and watch separately for cleaner logs
docker-compose up -d
docker-compose watch
```

**Features:**

- ✅ **Instant Updates**: Code changes automatically sync to running containers
- ✅ **Smart Ignoring**: Excludes `__pycache__/`, `*.pyc`, `.venv/`, `.adk/` files
- ✅ **Selective Rebuilds**: Only rebuilds when `requirements.txt` changes
- ✅ **Performance Optimized**: Better than bind mounts with intelligent file filtering

#### Option 2: Traditional Development

```bash
# Standard build and run
docker-compose up --build

# Rebuild specific service after changes
docker-compose up --build ai-agent -d
```

### Development Dockerfiles

- **AI Agent**: Uses production `Dockerfile` (watch-incompatible)
- **Frontend**: Uses `Dockerfile.dev` for watch compatibility (production uses distroless)
- **MCP Toolbox**: Uses pre-built image (no local development needed)

### Service Dependencies

- **Frontend** depends on **AI Agent** being ready
- **AI Agent** depends on **MCP Toolbox** being ready
- **MCP Toolbox** depends on **PostgreSQL** being ready

### Environment Configuration

#### AI Agent Environment Variables

- `GOOGLE_CLOUD_PROJECT`: Your Google Cloud project ID (configurable)
- `GOOGLE_CLOUD_LOCATION`: us-central1
- `GOOGLE_GENAI_USE_VERTEXAI`: "False" (uses Google AI API instead of Vertex AI)
- `GEMINI_MODEL_NAME`: "gemini-2.5-flash"
- `COMPANY_NAME`: "TechCorp" (customize for your organization)
- `ENABLE_CLOUD_TRACE`: "False"

#### Database Configuration

##### Development (Local PostgreSQL)

- `DB_HOST`: postgres
- `DB_PORT`: 5432
- `DB_USER`: mcpuser
- `DB_PASSWORD`: mcppassword
- `DB_NAME`: mcpdb

##### Production (Google Cloud SQL)

- `DB_PROJECT`: Your Google Cloud project ID
- `DB_REGION`: Database region (e.g., us-central1)
- `DB_INSTANCE`: Cloud SQL instance name
- `DB_USER`: Cloud SQL database user
- `DB_PASSWORD`: Cloud SQL database password
- `DB_NAME`: Database name

> **Note**: The MCP Toolbox uses different configuration files:
>
> - `tools.dev.yaml` for local development (connects to containerized PostgreSQL)
> - `tools.yaml` for production deployment (connects to Google Cloud SQL)

```text
├── ai-agent/                 # AI Agent service (Google ADK)
│   ├── Dockerfile
│   ├── main.py              # FastAPI entry point
│   ├── requirements.txt
│   └── corporate_agent/     # Sequential agent implementation
│       ├── __init__.py
│       ├── agent.py         # Retriever and presenter agents with Vega-Lite generation
│       ├── models.py        # Pydantic models for structured responses
│       └── .env            # Google API key configuration
├── frontend/                # Streamlit frontend
│   ├── Dockerfile           # Production build (distroless)
│   ├── Dockerfile.dev       # Development build (watch-compatible)
│   ├── streamlit_app.py     # Chat interface
│   └── requirements.txt
├── mcp-toolbox/            # Model Context Protocol toolbox
│   ├── Dockerfile
│   ├── tools.dev.yaml      # Development tools (local PostgreSQL)
│   └── tools.yaml          # Production tools (Google Cloud SQL)
├── iac/                    # Infrastructure as Code (Terraform)
│   └── README.md           # Infrastructure setup (in development)
└── docker-compose.yaml     # Complete service orchestration
```

## 🔧 Individual Services

### AI Agent

A FastAPI application built with Google's Agent Development Kit (ADK) featuring a **sequential agent architecture**:

- **Retriever Agent**: Specializes in SQL query generation and database operations using MCP tools
- **Presenter Agent**: Generates comprehensive analytical responses with interactive Vega-Lite visualizations
- **Intelligent Routing**: Automatically determines whether to provide text analysis or visual charts
- **Advanced Analytics**: Provides detailed insights, trend analysis, and business implications
- **Chart Generation**: Creates bar charts, time series, and comparative visualizations using real data

**Capabilities:**

- Natural language to SQL query translation
- Comprehensive business KPI analysis
- Customer, product, and sales analytics
- Automatic chart generation with proper data formatting
- Contextual analysis with business insights

### MCP Toolbox

A Model Context Protocol server that provides comprehensive database tools and analytics:

**Available Tools:**

- `list-tables`: Database schema discovery and table information
- `get-sales-kpis`: Key performance indicators and metrics
- `get-monthly-sales-trend`: Time series sales analysis
- `get-sales-by-category`: Product category performance
- `get-sales-by-region`: Geographic sales distribution
- `get-top-customers`: Customer ranking and analysis
- `search-products`: Product information and search
- `search-customers`: Customer lookup and details

**Features:**

- Secure database access layer
- Pre-built analytical queries
- Schema introspection
- Data validation and error handling

### Frontend

A Streamlit-based chat interface with advanced features:

**Features:**

- Natural language query input with chat interface
- Real-time streaming responses with loading status
- Interactive Vega-Lite chart rendering and visualization
- Persistent chat history that survives page refreshes
- Chart persistence across sessions
- Function call transparency showing database operations
- Error handling and validation for chart rendering
- Responsive design with status indicators

## 🌐 Deployment

### Local Development

Use the provided Docker Compose setup for local development and testing.

### Cloud Infrastructure

The `iac/` directory contains Terraform configurations for deploying to Google Cloud Platform using a **two-environment approach**:

#### Foundation Environment (`iac/foundation/`)

Sets up the core infrastructure that other resources depend on:

- **VPC Network**: Private network with subnet for Cloud Run services
- **Cloud SQL**: PostgreSQL database with private service access (development tier)
- **Service Accounts**: Dedicated accounts for each service with appropriate permissions
- **Artifact Registry**: Docker repository for container images
- **Secret Manager**: Regional secrets for database connection (no rotation)
- **APIs**: Enables all required Google Cloud APIs

#### Runtime Environment (`iac/runtime/`)

Deploys the Cloud Run services that make up the application:

**Services:**

- **Frontend Service** - Streamlit web interface (public access)
  - Resources: 1 CPU, 512Mi memory, scaling 0-2 instances
  - Port: 8501, public access via `allUsers`
- **AI Agent Service** - FastAPI backend with AI processing (internal access)
  - Resources: 2 CPU, 2Gi memory, scaling 0-2 instances
  - Port: 8000, internal only (invoked by frontend)
  - Database: Connected to Cloud SQL via IAM authentication
- **MCP Toolbox Service** - Tool server with database access (internal access)
  - Resources: 1 CPU, 1Gi memory, scaling 0-10 instances
  - Port: 8080, internal only (invoked by AI agent)
  - Database: Connected to Cloud SQL with direct connection attachment

**Networking & Security:**

- All services use direct VPC egress for private networking
- Services connect to Cloud SQL via private IP addresses
- IAM-based authentication for service-to-service communication
- Frontend is publicly accessible, backend services are internal-only
- Database authentication uses IAM (no passwords required)

#### Infrastructure Setup Process

##### Step 1: Deploy Foundation

The foundation environment creates all core infrastructure including the Artifact Registry repository.

1. Navigate to the foundation directory:

   ```bash
   cd iac/foundation
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. **IMPORTANT**: Create and configure terraform.auto.tfvars with your project details:

   ```bash
   # Create the terraform.auto.tfvars file if it doesn't exist
   touch terraform.auto.tfvars
   ```

   Then edit the file with your project configuration:

   ```hcl
   project_id = "your-gcp-project-id"  # REQUIRED: Your actual GCP project ID
   region = "us-central1"
   zone = "us-central1-a"

   # Optional: Customize resource names (defaults provided)
   artifact_registry_name = "smart-corporate-search"
   cloud_sql_instance_name = "corporate-search-db"
   cloud_sql_database_name = "corporate_data"
   ```

   > **⚠️ Required Configuration**: You MUST set your actual GCP project ID in the `project_id` variable before running terraform commands.

4. Deploy the foundation:

   ```bash
   terraform plan
   terraform apply
   ```

   This creates:

   - VPC network and subnet
   - Cloud SQL PostgreSQL instance
   - Service accounts for each service
   - **Artifact Registry repository** for container images
   - Google API Key secret in Secret Manager

##### Step 2: Build and Push Container Images

After foundation deployment successfully creates the Artifact Registry, build and push container images:

```bash
# Set your registry environment variable (replace with your actual project ID)
export REGISTRY="us-central1-docker.pkg.dev/YOUR_PROJECT_ID/smart-corporate-search"

# For PowerShell users:
# $env:REGISTRY = "us-central1-docker.pkg.dev/YOUR_PROJECT_ID/smart-corporate-search"

# Build and push AI Agent
gcloud builds submit ai-agent/ --tag $REGISTRY/ai-agent:latest

# Build and push Frontend
gcloud builds submit frontend/ --tag $REGISTRY/frontend:latest

# Build and push MCP Toolbox
gcloud builds submit mcp-toolbox/ --tag $REGISTRY/mcp-toolbox:latest
```

> **💡 Note**: The Artifact Registry repository is automatically created by the foundation deployment, so you don't need to create it manually.

##### Step 3: Create Secrets

Before deploying the runtime, you need to create the required secrets:

```bash
# Add the MCP tools configuration
gcloud secrets versions add mcp-tools-config --data-file="mcp-toolbox/tools.yaml"

# Set your Google API Key in the secret (replace with your actual API key)
echo -n "YOUR_GOOGLE_API_KEY_HERE" | gcloud secrets versions add google-api-key --data-file=-

# if you are using powershell, run the following instead:
# Save the Google API Key to a temp file
"YOUR_GOOGLE_API_KEY_HERE" | Out-File -Encoding ASCII temp_secret.txt -NoNewline

# Add it as a new version
gcloud secrets versions add google-api-key --data-file="temp_secret.txt"

# Clean up
Remove-Item temp_secret.txt
```

##### Step 4: Deploy Runtime

After building and pushing container images and creating the required secrets, deploy the runtime services:

```bash
cd iac/runtime
terraform init
```

Configure the runtime with container image URLs in `terraform.auto.tfvars`:

```hcl
project_id = "your-gcp-project-id"  # REQUIRED: Same project ID as foundation
region = "us-central1"

# Container Images (update with your actual image URLs)
frontend_container_image     = "us-central1-docker.pkg.dev/your-project/smart-corporate-search/frontend:latest"
ai_agent_container_image     = "us-central1-docker.pkg.dev/your-project/smart-corporate-search/ai-agent:latest"
mcp_toolbox_container_image  = "us-central1-docker.pkg.dev/your-project/smart-corporate-search/mcp-toolbox:latest"
```

> **⚠️ Required Configuration**: You MUST set container image URLs in `terraform.auto.tfvars` before deploying runtime resources. Use the artifact registry URL from your foundation deployment.

Deploy the runtime:

```bash
terraform plan
terraform apply
```

After deployment, you'll get service URLs for accessing your application:

- Frontend service URL (publicly accessible)
- AI Agent service URL (internal)
- MCP Toolbox service URL (internal)

#### Configurable Variables

The foundation environment supports customization through variables:

| Variable                         | Default                        | Description                    |
| -------------------------------- | ------------------------------ | ------------------------------ |
| `artifact_registry_name`         | `smart-corporate-search`       | Name of the Docker repository  |
| `cloud_sql_instance_name`        | `corporate-search-db`          | Cloud SQL instance name        |
| `cloud_sql_database_name`        | `corporate_data`               | Database name                  |
| `vpc_name`                       | `corporate-search-vpc`         | VPC network name               |
| `subnet_name`                    | `corporate-search-subnet`      | Subnet name                    |
| `frontend_service_account_id`    | `corporate-agent-frontend-svc` | Frontend service account ID    |
| `ai_agent_service_account_id`    | `corporate-agent-ai-agent-svc` | AI Agent service account ID    |
| `mcp_toolbox_service_account_id` | `corporate-agent-mcp-svc`      | MCP Toolbox service account ID |

## 📝 Usage Examples

The system provides intelligent analysis with detailed insights and visualizations:

### Business Analytics Queries

- **"Who is our biggest customer by total revenue?"**
  - Provides detailed analysis with specific revenue figures, percentage of total business, and comparative insights
- **"What was the revenue per month for January to July 2024?"**
  - Generates interactive bar charts with monthly trends and identifies peak/low periods
- **"Give me the top 2 customers who made the most purchases in 2024"**
  - Creates comparative visualizations with detailed spending analysis and business relationship insights

### Sample Response Types

**Text Analysis:**

```text
TechCorp's biggest customer by total revenue is Cyberdyne Systems, with a total spend of $182,855.58. This highlights Cyberdyne Systems as a key account and a significant contributor to our overall revenue.
```

**Visual Analysis:**

- Interactive charts showing trends, comparisons, and distributions
- Detailed analytical insights explaining what the data reveals
- Business implications and actionable recommendations
- Comparative analysis with context and percentages

The AI agents automatically determine whether to provide text analysis or visual charts based on the query type and data characteristics.

## 🔒 Security Notes

- API keys are stored in `.env` files and not committed to version control
- Database access is containerized and isolated
- CORS is configured for secure frontend-backend communication
- All services run in isolated Docker containers

## 🤝 Contributing

This project is actively under development. The AI agent orchestration and MCP toolbox capabilities will be expanded with additional features and tools.

## 📄 License

MIT - See the [LICENSE](LICENSE) file for details.

---

**Status**: ✅ Production Ready

- ✅ Docker orchestration and service setup
- ✅ Advanced frontend chat interface with chart rendering
- ✅ Sequential AI agent system with specialized retriever and presenter agents
- ✅ Comprehensive MCP toolbox with SQL analytics tools
- ✅ Interactive Vega-Lite chart generation and visualization
- ✅ Persistent chat history and chart storage
- ✅ Detailed analytical insights and business intelligence
- ✅ Foundation infrastructure with VPC, Cloud SQL, and service accounts
- ✅ Runtime Cloud Run services with auto-scaling and IAM authentication
