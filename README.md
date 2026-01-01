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

### Cloud Infrastructure (Coming Soon)

The `iac/` directory contains Terraform configurations for deploying to Google Cloud Platform:

- Cloud Run services
- Cloud SQL databases
- Artifact Registry
- IAM configurations
- Secret Management

_Note: Cloud deployment infrastructure is currently in development._

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
- 🚧 Cloud deployment infrastructure
