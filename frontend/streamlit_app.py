import random
import time
import os
import requests
from google.auth.transport.requests import Request
from google.oauth2 import id_token

import streamlit as st


def get_user_id():
    """Generate a persistent user ID that survives browser refreshes."""
    if "user_id" not in st.session_state:
        timestamp = int(time.time() * 1000)  # milliseconds for uniqueness
        random_part = random.randint(1000, 9999)
        st.session_state.user_id = f"user_{timestamp}_{random_part}"
    return st.session_state.user_id


def get_session_id():
    """Get or create a session ID for the current session."""
    if "session_id" not in st.session_state:
        timestamp = int(time.time() * 1000)
        random_part = random.randint(1000, 9999)
        st.session_state.session_id = f"session_{timestamp}_{random_part}"
    return st.session_state.session_id


def ensure_user_session(ai_agent_url: str, user_id: str, session_id: str, headers: dict):
    """Ensure the user session exists in ADK by creating it if necessary."""
    # Check if we've already successfully created the session
    session_key = f"user_session_created_{user_id}_{session_id}"
    if session_key in st.session_state and st.session_state[session_key] == True:
        return True

    try:
        # Create user session with ADK
        session_url = f"{ai_agent_url}/apps/corporate_agent/users/{user_id}/sessions/{session_id}"
        response = requests.patch(
            session_url,
            json={"type": "anonymous"},
            headers=headers,
            timeout=10
        )
        response.raise_for_status()

        # Cache the success status
        st.session_state[session_key] = True
        return True
    except requests.RequestException as e:
        st.error(f"Failed to create user session: {e}")
        return False


def generate_ai_response(prompt: str):
    """Generate AI response by calling the AI agent service with ADK format."""
    ai_agent_url = os.getenv("AI_AGENT_URL")
    if not ai_agent_url:
        raise ValueError("AI_AGENT_URL environment variable is required")

    # Get or create user and session IDs
    user_id = get_user_id()
    session_id = get_session_id()

    try:
        token = id_token.fetch_id_token(Request(), ai_agent_url)
        headers = {"Authorization": f"Bearer {token}",
                   "Content-Type": "application/json"}
    except Exception:
        headers = {"Content-Type": "application/json"}

    # Ensure user session exists
    if not ensure_user_session(ai_agent_url, user_id, session_id, headers):
        return {"error": "Failed to create user session"}

    # Prepare ADK request format
    adk_request = {
        "appName": "corporate_agent",
        "userId": user_id,
        "sessionId": session_id,
        "newMessage": {
            "role": "user",
            "parts": [{
                "text": prompt
            }]
        },
    }

    try:
        response = requests.post(
            f"{ai_agent_url}/run",
            json=adk_request,
            headers=headers,
            timeout=60
        )
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        st.error(f"Failed to get AI response: {e}")
        return {"error": str(e)}


# Streamed response emulator
def response_generator():
    response = random.choice(
        [
            "Hello there! How can I assist you today?",
            "Hi, human! Is there anything I can help you with?",
            "Do you need help?",
        ]
    )
    for word in response.split():
        yield word + " "
        time.sleep(0.07)


st.set_page_config(page_title="The Smart Corporate Search", page_icon="🤖")
st.title("The Smart Corporate Search")
st.caption(
    "An Internal RAG application where you can use natural language to ask questions about your internal systems like 'Who is our biggest customer by total revenue?'"
)

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "Hello there 👋, how can I help you today?"}
    ]

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])


if prompt := st.chat_input("What do you want to know?"):
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    # formulate ai response
    with st.chat_message("assistant"):
        response = st.write_stream(response_generator())
    st.session_state.messages.append(
        {"role": "assistant", "content": response})  # type: ignore
