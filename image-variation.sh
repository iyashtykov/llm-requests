#!/bin/bash

# --- Configuration ---
IMAGE_PATH="great.png"
SUB_PATH="/images/variations"
LLM_URL="${OPENAI_BASE_URL%/}${SUB_PATH}"
MODEL="dall-e-2"
# 1. Validation
if [[ ! -f "$IMAGE_PATH" ]]; then
    echo "Error: File '$IMAGE_PATH' not found."
    exit 1
fi

echo "--- Debugging Variation Request ---"
echo "URL: $LLM_URL"

# 2. Execute Request with full Verbose mode
# -v : verbose mode (shows headers and connection info)
# --trace-ascii : logs everything to a file for review
response=$(curl -v -X POST "$LLM_URL" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "image=@$IMAGE_PATH" \
  -F "model=$MODEL" \
  -F "n=1" \
  -F "size=1024x1024" \
  -F "response_format=b64_json" \
  2> curl_debug.log)

# 3. Check if response is empty
if [[ -z "$response" ]]; then
    echo "!!! SERVER RETURNED ABSOLUTELY NOTHING !!!"
    echo "Check 'curl_debug.log' to see if the connection was reset."
    tail -n 20 curl_debug.log
    exit 1
fi

# 4. Check for 502/HTML again
if [[ "$response" == *"<html"* ]]; then
    echo "Result: Server returned HTML (Error page)."
    # Extract only the title or first few lines of HTML
    echo "$response" | head -n 10
    exit 1
fi

# 5. Final attempt to parse
img_data=$(echo "$response" | jq -r '.data[0].b64_json // empty' 2>/dev/null)

if [[ -n "$img_data" ]]; then
    echo "$img_data" | base64 --decode > variation_output.png
    echo "Success: Saved to variation_output.png"
else
    echo "Could not find image data in response."
    echo "Raw Response: $response"
fi