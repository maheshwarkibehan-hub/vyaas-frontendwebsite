#!/bin/bash

# Start the API server in the background
# Render provides the PORT environment variable
uvicorn server:app --host 0.0.0.0 --port $PORT &

# Start the LiveKit Agent
python agent.py start
