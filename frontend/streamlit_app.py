import random
import time

import streamlit as st


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
