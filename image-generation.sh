#!/bin/bash

# --- Config ---
# Ensure OPENAI_BASE_URL and OPENAI_API_KEY are exported in your shell
MODEL="dall-e-3" 
PROMPT="flying dog ghibli style"
SIZE="1024x1024"
SUB_PATH="/images/generations"

# Safely combine URL (removes trailing slash from base if present)
BASE_CLEAN="${OPENAI_BASE_URL%/}"
LLM_URL="${BASE_CLEAN}${SUB_PATH}"

echo "--- Sending Request to $LLM_URL ---"

# 1. Execute request
# -s: silent (no progress bar)
# -S: show errors if it fails
# --stderr -: redirects debug info to stdout/terminal instead of a file
response=$(curl -sS -X POST "$LLM_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"model\": \"$MODEL\",
    \"prompt\": \"$PROMPT\",
    \"n\": 1,
    \"size\": \"$SIZE\",
    \"response_format\": \"b64_json\"
  }")

# 2. Basic check if response is empty
if [[ -z "$response" ]]; then
    echo "Error: Received empty response from server."
    exit 1
fi

# 3. Try to extract data or error message
img_data=$(echo "$response" | jq -r '.data[0].b64_json // empty')
error_msg=$(echo "$response" | jq -r '.error.message // empty')

# 4. Final Logic
if [[ -n "$img_data" ]]; then
    echo "$img_data" | base64 --decode > great.png
    echo "Success: Image saved to great.png"
elif [[ -n "$error_msg" ]]; then
    echo "API Error: $error_msg"
    exit 1
else
    echo "Unknown Error. Full response:"
    echo "$response"
    exit 1
fi