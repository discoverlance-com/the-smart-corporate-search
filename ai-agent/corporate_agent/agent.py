from google.adk.agents.llm_agent import Agent
from google.adk.agents.sequential_agent import SequentialAgent
from google.genai import types
from toolbox_core import ToolboxSyncClient, auth_methods
import os
from .models import FinalPresentation

GEMINI_QUERY_ANALYST_MODEL_NAME = os.getenv(
    "GEMINI_QUERY_ANALYST_MODEL_NAME", "gemini-2.5-pro")
GEMINI_PRESENTER_MODEL_NAME = os.getenv(
    "GEMINI_PRESENTER_MODEL_NAME", "gemini-2.5-flash")
COMPANY_NAME = os.getenv("COMPANY_NAME", "TechCorp")
MCP_TOOLBOX_SERVICE_URL = os.getenv("MCP_TOOLBOX_SERVICE_URL")

if not MCP_TOOLBOX_SERVICE_URL:
    raise ValueError(
        "MCP_TOOLBOX_SERVICE_URL environment variable is not set.")


def get_toolbox_client():
    """Get toolbox client with fresh authentication for each request."""
    if not MCP_TOOLBOX_SERVICE_URL:
        raise ValueError(
            "MCP_TOOLBOX_SERVICE_URL environment variable is required")

    try:
        # Try without authentication first (for local development)
        return ToolboxSyncClient(url=MCP_TOOLBOX_SERVICE_URL)
    except Exception:
        # Use fresh auth token for each request (handles token expiration)
        auth_token_provider = auth_methods.get_google_id_token(
            MCP_TOOLBOX_SERVICE_URL)
        return ToolboxSyncClient(
            url=MCP_TOOLBOX_SERVICE_URL,
            client_headers={"Authorization": auth_token_provider}
        )


def get_sql_toolset():
    """Get SQL toolset with fresh toolbox client."""
    toolbox = get_toolbox_client()
    try:
        return toolbox.load_toolset("ecommerce-toolset")
    except Exception:
        return []


# Initialize toolset
sql_toolset = get_sql_toolset()

STATE_QUERY_DATA = "sql_query_data"
STATE_COMPLETION_PHRASE = "SQL_QUERY_COMPLETED"
STATE_QUERY_CRITIQUE = "sql_query_critique"

retriever_agent = Agent(
    name="retriever_agent",
    model=GEMINI_QUERY_ANALYST_MODEL_NAME,
    tools=sql_toolset,  # type: ignore
    description="""A Data Retriever agent capable of querying information from a corporate PostgreSQL database. It uses available tools perform the query.""",
    instruction=f"""
    You are a Senior Data Retriever for '{COMPANY_NAME}'. Your goal is to answer user questions by querying the corporate database. 
    
    **Your Workflow:**

    **Step 1: Discovery**
    - ALWAYS start by using the `list-tables` tool to discover available database tables and their schemas
    - This gives you the current database structure without guessing
    
    **Step 2: Analysis**
    - Based on the user's question and discovered schema, determine which tools are most appropriate
    - Available tools include: list-tables, get-sales-kpis, get-monthly-sales-trend, get-sales-by-category, get-sales-by-region, get-top-customers, search-products, search-customers
    
    **Step 3: Execution**
    - Execute the appropriate tool(s) to get the requested information
    - Use date ranges like '2024-01-01' to '2024-12-31' when tools require date parameters
    
    **Decision Logic:**
    - IF the request cannot be answered with available tools, return: {{"status": "irrelevant"}}
    - ELSE proceed to get and return the data
    
    **Important:** 
    - Never assume database structure - always discover first using list-tables
    - Use the specific tools designed for common business queries
    - Provide date ranges in YYYY-MM-DD format when required
    """,
    output_key=STATE_QUERY_DATA,
    include_contents='none',
    generate_content_config=types.GenerateContentConfig(
        temperature=0.1,
        max_output_tokens=2048,
        safety_settings=[
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=types.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            )
        ]
    ),
)

presenter_agent = Agent(
    name="presenter_agent",
    model=GEMINI_PRESENTER_MODEL_NAME,
    description="""A specialized agent that presents the final query results from the user's question in a user-friendly format.""",
    instruction=f"""
    You are a Senior Data Presenter for '{COMPANY_NAME}'. Format query results based on the user's question in a clear and engaging manner.
    
    **Query Results**: {{sql_query_data}}

    **Your Output Options:**

    **Case 1: Unable to Answer**
    - If results contain {{"status": "irrelevant"}} or errors
    - `response_type`: "unable_to_answer"
    - `summary_text`: Clear explanation of why (e.g., "I cannot answer this because the data requested is not available in our database")
    - `vega_lite_spec`: null

    **Case 2: Visual Representation**
    - If data shows trends, comparisons, distributions, or user asks for charts/graphs
    - `response_type`: "visual"
    - `summary_text`: Provide detailed analytical insights including:
      * Key findings and patterns in the data
      * Specific numbers, percentages, and comparisons
      * Notable trends, peaks, or anomalies
      * Business implications or observations
      * Context about what the data reveals
      Example: "Cyberdyne Systems leads with $847,329 in total purchases, significantly outpacing Acme Corp's $623,441. This represents a 36% gap between the top two customers. Notably, Cyberdyne's spending shows consistent high-value transactions throughout 2024, indicating strong business relationship stability."
    - `vega_lite_spec`: REQUIRED complete Vega-Lite specification dictionary (never null or empty)

    **Case 3: Text Summary**
    - If data is best presented as numbers, lists, or specific values
    - `response_type`: "text"
    - `summary_text`: Provide comprehensive analytical insights including:
      * Direct answer to the user's question with specific data
      * Contextual analysis and interpretation of the numbers
      * Comparative insights (vs previous periods, benchmarks, etc.)
      * Trends, patterns, or notable observations in the data
      * Business implications and actionable insights
      * Supporting details that explain the "why" behind the numbers
      Example: "TechCorp's biggest customer by total revenue is Cyberdyne Systems with $847,329 in 2024 purchases, representing 18% of total customer revenue. This customer shows remarkable consistency with average monthly orders of $70,610, significantly above our $24,000 customer average. Their purchasing pattern indicates strong product adoption and suggests potential for expanded business relationship. The next closest customer, Acme Corp at $623,441, represents a notable 26% gap, highlighting Cyberdyne's exceptional value to our business."
    - `vega_lite_spec`: null

    **CRITICAL: Vega-Lite Spec Format**
    
    For monthly revenue questions, you MUST generate vega_lite_spec as a JSON STRING:
    
    ```
    {{
        "response_type": "visual",
        "summary_text": "Here's the monthly revenue breakdown...",
        "vega_lite_spec": "{{\\"$schema\\": \\"https://vega.github.io/schema/vega-lite/v5.json\\", \\"title\\": \\"Monthly Revenue for January - July 2024\\", \\"data\\": {{\\"values\\": [{{\\"month\\": \\"Jan\\", \\"revenue\\": 29230.95}}, {{\\"month\\": \\"Feb\\", \\"revenue\\": 16170.99}}, {{\\"month\\": \\"Mar\\", \\"revenue\\": 26904.33}}, {{\\"month\\": \\"Apr\\", \\"revenue\\": 35043.38}}, {{\\"month\\": \\"May\\", \\"revenue\\": 119965.98}}, {{\\"month\\": \\"Jun\\", \\"revenue\\": 12871.49}}, {{\\"month\\": \\"Jul\\", \\"revenue\\": 39982.35}}]}}, \\"mark\\": \\"bar\\", \\"encoding\\": {{\\"x\\": {{\\"field\\": \\"month\\", \\"type\\": \\"nominal\\", \\"title\\": \\"Month\\"}}, \\"y\\": {{\\"field\\": \\"revenue\\", \\"type\\": \\"quantitative\\", \\"title\\": \\"Revenue ($)\\"}}}}}}"
    }}
    ```
    
    CRITICAL: Generate vega_lite_spec as a SINGLE JSON STRING with proper escaping.
    
    **CRITICAL INSTRUCTIONS:**
    - Look at the query results in {{sql_query_data}} and extract the ACTUAL numbers and values
    - Transform the query data into the exact format needed for the chart
    - Never use placeholder data, null values, or empty arrays
    - If the query returned monthly revenue data, use those exact values in your chart
    - NEVER set "data": null or "encoding": null - always provide complete objects
    - The data field must ALWAYS be a dictionary with a "values" array containing the actual data
    - The encoding field must ALWAYS be a dictionary with properly defined "x" and "y" mappings

    **Key Requirements:**
    1. vega_lite_spec must be a complete dictionary object (never null)
    2. data.values must contain actual numbers from the query results
    3. encoding must define both x and y fields (never null)
    4. Extract real data from {{sql_query_data}} and use it in the chart
    5. If you have monthly revenue data showing values like 119965.98, use those exact numbers

    **Rules:**
    - `data.values` must be an array of objects with consistent field names
    - `encoding` must be an object with field mappings (x, y, color, etc.)
    - Never put descriptive text in `data` or `encoding` - only structured JSON
    - Use appropriate field types: "quantitative" for numbers, "nominal" for categories, "temporal" for dates
    - Always include meaningful titles for axes

    **Quality Guidelines:**
    - Make summaries conversational and business-focused
    - For visuals, choose appropriate chart types and include titles/labels
    - Always provide context and insights, not just raw data
    """,
    output_schema=FinalPresentation,
    generate_content_config=types.GenerateContentConfig(
        temperature=0.3,
        max_output_tokens=3072,
        safety_settings=[
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=types.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            )
        ]
    ),
)

root_agent = SequentialAgent(
    name='corporate_agent',
    sub_agents=[retriever_agent, presenter_agent],
    description="An agent that retrieves data from a corporate database and presents the results to the user in a friendly format.",
)
