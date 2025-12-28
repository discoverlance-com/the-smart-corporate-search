# Builder Stage
FROM python:3.13-slim AS builder
WORKDIR /app

COPY requirements.txt .
COPY .streamlit/config.toml .
RUN pip install --no-cache-dir -r requirements.txt -t /app/site-packages

COPY streamlit_app.py /app/streamlit_app.py

# Runtime Stage
FROM gcr.io/distroless/python3-debian12

WORKDIR /app
ENV PYTHONPATH=/app/site-packages
ENV PYTHONUNBUFFERED=1

COPY --from=builder /app/site-packages /app/site-packages
COPY --from=builder /app/streamlit_app.py /app/streamlit_app.py
COPY --from=builder /app/config.toml /app/.streamlit/config.toml

USER nonroot

EXPOSE 8080

# we cannot execute the 'streamlit' binary in distroless
# we instead execute the 'streamlit' module directly with -m
CMD ["-m", "streamlit", "run", "streamlit_app.py", "--server.port=8080", "--server.address=0.0.0.0"]
