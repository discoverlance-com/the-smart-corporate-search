# The Smart Corporate Search - AI Agent

This project uses Google ADK as the AI orchestration tool. The project is setup with a google adk `corporate_agent` that is responsible for receiving user queries and returning a response.

FAST API is used to setup in `main.py` to setup google adk for Cloud Run.

## Local Development and Testing

### Using gcloud CLI

You can test the Cloud Run service locally with the gcloud CLI.

To start the local development environment, first setup your service by creating a `service.dev.yaml` file with the following structure and replace places indicated with comments:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: corporate-ai-agent # replace this with the service name
spec:
  template:
    spec:
      containers:
        - env:
            - name: GOOGLE_CLOUD_PROJECT
              value: # place your project id here
            - name: GOOGLE_CLOUD_LOCATION
              value: us-central1 # replace this with your region
            - name: GOOGLE_GENAI_USE_VERTEXAI
              value: "False" # change this to 1 if using vertex ai
            - name: GOOGLE_API_KEY
              value: # replace this with your api key
            - name: ENABLE_CLOUD_TRACE
              value: "False" # replace this with True when you want to enable cloud trace
```

Then, go ahead to run the service locally with the command:

```bash
# if you have not already logged in with application default credential, login with the command:
gcloud auth application-default login
# Run the service and give it permission to use Google Cloud services:
gcloud beta code dev --application-default-credential
# else you can run it without the permission to use Google Cloud services
gcloud beta code dev
```

## Deployment

Set up the environment variables:

```bash
export GOOGLE_CLOUD_PROJECT=your-project-id
export GOOGLE_CLOUD_LOCATION=us-central1 # Or your preferred location
export GOOGLE_GENAI_USE_VERTEXAI=True # change to False if you are using GOOGLE_API_KEY
```

Deploy with gcloud

```bash
gcloud run deploy corporage-agent \
--source . \
--region $GOOGLE_CLOUD_LOCATION \
--project $GOOGLE_CLOUD_PROJECT \
--set-env-vars="GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,GOOGLE_CLOUD_LOCATION=$GOOGLE_CLOUD_LOCATION,GOOGLE_GENAI_USE_VERTEXAI=$GOOGLE_GENAI_USE_VERTEXAI"
# Add any other necessary environment variables your agent might need including the GOOGLE_API_KEY which you might want to use as a secret

```
