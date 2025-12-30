from google.adk.agents.llm_agent import Agent
from google.genai import types
from google.adk.tools.tool_context import ToolContext
import os
from pydantic import BaseModel, Field
from .tools import exit_loop

GEMINI_MODEL_NAME = os.getenv("GEMINI_MODEL_NAME", "gemini-2.5-flash")
GEMINI_SQL_REVIEWER_MODEL_NAME = os.getenv(
    "GEMINI_SQL_REVIEWER_MODEL_NAME", "gemini-2.5-flash")
GEMINI_SQL_ANALYST_MODEL_NAME = os.getenv(
    "GEMINI_SQL_ANALYST_MODEL_NAME", "gemini-2.5-pro")
COMPANY_NAME = os.getenv("COMPANY_NAME", "TechCorp")

STATE_SQL_DATA = "sql_query_data"
STATE_COMPLETION_PHRASE = "SQL_QUERY_COMPLETED"
STATE_SQL_CRITIQUE = "sql_query_critique"
STATE_USER_QUESTION = "user_question"

root_agent = Agent(
    model=GEMINI_MODEL_NAME,
    name='corporate_agent',
    description="agent_description",
    instruction="agent_instruction",
    generate_content_config=types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=4096,
        safety_settings=[
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=types.HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            )
        ]
    ),
)
