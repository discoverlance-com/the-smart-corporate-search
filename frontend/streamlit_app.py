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
        timestamp = int(time.time() * 1000)
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
    session_key = f"user_session_created_{user_id}_{session_id}"
    if session_key in st.session_state and st.session_state[session_key] == True:
        return True

    try:
        session_url = f"{ai_agent_url}/apps/corporate_agent/users/{user_id}/sessions/{session_id}"
        response = requests.post(
            session_url,
            json={"stateDelta": {"type": "anonymous"}},
            headers=headers,
            timeout=10
        )
        response.raise_for_status()
        st.session_state[session_key] = True
        return True
    except requests.HTTPError as e:
        if e.response.status_code == 409:
            # Session already exists
            st.session_state[session_key] = True
            return True
        raise e
    except requests.RequestException as e:

        st.error(f"Failed to create user session: {e}")
        return False


def generate_ai_response(prompt: str):
    """Generate AI response by calling the AI agent service with ADK format."""
    ai_agent_url = os.getenv("AI_AGENT_URL")
    if not ai_agent_url:
        raise ValueError("AI_AGENT_URL environment variable is required")

    user_id = get_user_id()
    session_id = get_session_id()

    try:
        token = id_token.fetch_id_token(Request(), ai_agent_url)
        headers = {"Authorization": f"Bearer {token}",
                   "Content-Type": "application/json"}
    except Exception:
        headers = {"Content-Type": "application/json"}

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


def response_generator(prompt: str):
    """Generate AI response with loading status and proper parsing."""
    import json

    with st.status("🔍 Analyzing your question...", expanded=True) as status:
        st.write("🤖 AI agent is generating response...")
        response_data = generate_ai_response(prompt)

        if "error" in response_data:
            status.update(label="❌ Error occurred", state="error")
            st.error(f"Failed to get response: {response_data['error']}")
            return "Sorry, I encountered an error while processing your request."

        st.write("📊 Processing database queries...")

        response_array = response_data if isinstance(
            response_data, list) else []

        function_calls = []
        final_response = None

        for item in response_array:
            if "content" in item and "parts" in item["content"]:
                for part in item["content"]["parts"]:
                    if "functionCall" in part:
                        func_call = part["functionCall"]
                        function_calls.append({
                            "name": func_call.get("name", "unknown"),
                            "args": func_call.get("args", {})
                        })

            if item.get("author") == "presenter_agent" and "content" in item:
                for part in item["content"]["parts"]:
                    if "text" in part:
                        try:
                            final_response = json.loads(part["text"])
                        except json.JSONDecodeError:
                            pass

        if function_calls:
            st.write("🛠️ **Database Operations:**")
            for i, func in enumerate(function_calls, 1):
                with st.expander(f"Query {i}: {func['name']}", expanded=False):
                    if func['args']:
                        for key, value in func['args'].items():
                            st.text(f"{key}: {value}")
                    else:
                        st.text("No parameters")

        status.update(label="✅ Analysis complete", state="complete")

    if final_response:
        response_type = final_response.get("response_type", "text")
        summary_text = final_response.get(
            "summary_text", "No response available.")
        vega_lite_spec = final_response.get("vega_lite_spec", None)

        if response_type == "visual" and vega_lite_spec:
            try:
                import json
                if isinstance(vega_lite_spec, str):
                    chart_spec = json.loads(vega_lite_spec)
                else:
                    chart_spec = vega_lite_spec
                # Validate chart spec has required fields and isn't just empty dict
                if (not chart_spec or
                    not chart_spec.get('data') or
                    not chart_spec.get('encoding') or
                        chart_spec == {}):
                    st.error(
                        "Chart specification is missing data or encoding. The AI agent may not have generated complete chart data.")
                    st.write("Received chart spec:", chart_spec)
                    return {
                        "content": f"📊 **Chart Response** (Incomplete chart data)\n\n{summary_text}",
                        "response_type": "error"
                    }

                # Ensure data field is a dict, not a string
                if 'data' in chart_spec and isinstance(chart_spec['data'], str):
                    chart_spec['data'] = json.loads(chart_spec['data'])
                if 'encoding' in chart_spec and isinstance(chart_spec['encoding'], str):
                    chart_spec['encoding'] = json.loads(chart_spec['encoding'])

                st.vega_lite_chart(chart_spec)
                return {
                    "content": f"📊 **Chart Summary**\n\n{summary_text}",
                    "chart_spec": chart_spec,
                    "response_type": "visual"
                }
            except (json.JSONDecodeError, Exception) as e:
                st.error(f"Error rendering chart: {e}")
                return {
                    "content": f"📊 **Chart Response** (Error in chart data)\n\n{summary_text}",
                    "response_type": "error"
                }
        elif response_type == "unable_to_answer":
            return {
                "content": f"❓ **Information Unavailable**\n\n{summary_text}",
                "response_type": "unable_to_answer"
            }
        else:
            return {
                "content": f"📋 **Analysis Result**\n\n{summary_text}",
                "response_type": "text"
            }

    return {"content": "No valid response received from the AI agent.", "response_type": "error"}


st.set_page_config(page_title="The Smart Corporate Search", page_icon="🤖")
st.title("The Smart Corporate Search")
st.caption(
    "An Internal RAG application where you can use natural language to ask questions about your internal systems like 'Who is our biggest customer by total revenue?'"
)

if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "Hello there 👋, how can I help you today?"}
    ]

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        content = message["content"]
        if isinstance(content, dict):
            chart_spec = content.get("chart_spec")
            if chart_spec:
                try:
                    st.vega_lite_chart(chart_spec)
                except Exception as e:
                    st.error(f"Error displaying saved chart: {e}")

            content_text = content.get("content", "")
            if content_text:
                st.markdown(content_text)

        else:
            st.markdown(content)


if prompt := st.chat_input("What do you want to know?"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        response = response_generator(prompt)
        if isinstance(response, dict):
            st.markdown(response["content"])
        else:
            st.markdown(response)
    st.session_state.messages.append(
        {"role": "assistant", "content": response})  # type: ignore
