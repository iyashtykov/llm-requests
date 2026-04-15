#!/bin/bash

# Configuration
MODEL="gpt-4o-mini-transcribe"
SUB_PATH="/audio/transcriptions"
LLM_URL="${OPENAI_BASE_URL%/}${SUB_PATH}"
AUDIO_FILE="speech.mp3"

echo "--- STT Debug: Solving 'verbose_json' issue ---"

if [[ ! -f "$AUDIO_FILE" ]]; then
    echo "Error: $AUDIO_FILE not found."
    exit 1
fi

response=$(curl -sS -v -X POST "$LLM_URL" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F "file=@$AUDIO_FILE" \
  -F "model=$MODEL" \
  -F "response_format=json" \
  2>&1)

echo "--- Full Verbose Log ---"
echo "$response"


echo "--- Analysis ---"
if echo "$response" | grep -q "verbose_json"; then
    echo "DETECTED: The proxy is forcing 'verbose_json' even if we send 'json'."
fi