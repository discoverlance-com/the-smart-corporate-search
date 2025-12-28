import os

import uvicorn
from fastapi import FastAPI
from google.adk.cli.fast_api import get_fast_api_app

# Get the directory where main.py is located
AGENT_DIR = os.path.dirname(os.path.abspath(__file__))
# Note: Use 'sqlite+aiosqlite' instead of 'sqlite' because DatabaseSessionService requires an async driver
SESSION_SERVICE_URI = "sqlite+aiosqlite:///./sessions.db"
# Allowed origins for CORS
ALLOWED_ORIGINS = []
# No web interface
SERVE_WEB_INTERFACE = False

# Enable cloud trace
ENABLE_CLOUD_TRACE = os.getenv("ENABLE_CLOUD_TRACE", "False").lower() == "true"

# Call the function to get the FastAPI app instance
# Ensure the agent directory name ('corporate_agent') matches your agent folder
app: FastAPI = get_fast_api_app(
    agents_dir=AGENT_DIR,
    session_service_uri=SESSION_SERVICE_URI,
    allow_origins=ALLOWED_ORIGINS,
    web=SERVE_WEB_INTERFACE,
    trace_to_cloud=ENABLE_CLOUD_TRACE  # setup cloud trace
)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
