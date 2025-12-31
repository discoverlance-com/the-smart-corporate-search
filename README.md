# The Smart Corporate Search 🤖

An intelligent internal RAG (Retrieval Augmented Generation) application that allows you to query your internal systems using natural language. Ask questions like "Who is our biggest customer by total revenue?" and get instant answers powered by AI agents and your corporate data.

## 🏗️ Architecture

This project consists of four main components that work together to deliver intelligent corporate search capabilities:

```text
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │───▶│  AI Agent   │───▶│ MCP Toolbox │───▶│ PostgreSQL  │
│ (Streamlit) │    │  (FastAPI)  │    │   (Tools)   │    │ (Database)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Components

- **Frontend (Port 8501)**: Streamlit-based chat interface where users interact with the system using natural language queries
- **AI Agent (Port 8080)**: FastAPI application powered by Google ADK (Agent Development Kit) that orchestrates multiple AI agents to understand queries and generate responses
- **MCP Toolbox (Port 8081)**: Model Context Protocol server that exposes SQL tools and database operations for the AI agents to use
- **PostgreSQL (Port 5432)**: Database containing your corporate data that powers the search and analytics

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Google AI API Key (Gemini)
- Your corporate data loaded into PostgreSQL

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
│   └── corporate_agent/     # Agent implementation
│       ├── __init__.py
│       ├── agent.py         # Agent logic (in development)
│       ├── tools.py         # Agent tools (in development)
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

A FastAPI application built with Google's Agent Development Kit (ADK) that will orchestrate multiple AI agents to:

- Understand natural language queries
- Determine what data to retrieve
- Generate appropriate responses (text or graphs)
- Coordinate with the MCP Toolbox for data operations

_Note: The agent implementation is currently in development and will be enhanced with multi-agent capabilities._

### MCP Toolbox

A Model Context Protocol server that exposes database tools and operations:

- SQL query execution
- Schema introspection
- Data retrieval and analysis tools
- Secure database access layer

_Note: Additional tools and capabilities are being developed._

### Frontend

A Streamlit-based chat interface that provides:

- Natural language query input
- Real-time streaming responses
- Chat history
- Interactive visualizations (coming soon)

## 🌐 Deployment

### Local Development

Use the provided Docker Compose setup for local development and testing.

### Cloud Infrastructure (Coming Soon)

The `iac/` directory contains Terraform configurations for deploying to Google Cloud Platform:

- Cloud Run services
- Cloud SQL databases
- Artifact Registry
- IAM configurations
- Secret Management

_Note: Cloud deployment infrastructure is currently in development._

## 📝 Usage Examples

Once running, you can ask questions like:

- "Who is our biggest customer by total revenue?"
- "Show me sales trends for the last quarter"
- "What are our top performing products?"
- "How many new customers did we acquire this month?"

The AI agents will understand your query, fetch the appropriate data using SQL tools, and provide comprehensive answers with visualizations where appropriate.

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

**Status**: 🚧 Active Development

- ✅ Docker orchestration and service setup
- ✅ Basic frontend chat interface
- 🚧 AI agent multi-agent system
- 🚧 MCP toolbox SQL tools expansion
- 🚧 Cloud deployment infrastructure
- 🔄 Graph generation and advanced visualizations
