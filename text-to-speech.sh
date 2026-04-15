#!/bin/bash

MODEL="gpt-4o-mini-tts"
SUB_PATH="/audio/speech"
LLM_URL="${OPENAI_BASE_URL%/}${SUB_PATH}"

echo "--- TTS Debug Start ---"


curl -s -D headers.tmp -X POST "$LLM_URL" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"input\": \"This is a great debug script to convert text to speech!\",
    \"voice\": \"alloy\"
  }" \
  -o body.tmp


HTTP_STATUS=$(grep "HTTP/" headers.tmp | tail -1 | awk '{print $2}')
CONTENT_TYPE=$(grep -i "content-type" headers.tmp | awk '{print $2}')

echo "HTTP Status: $HTTP_STATUS"
echo "Content-Type: $CONTENT_TYPE"

if [ "$HTTP_STATUS" == "200" ]; then
    mv body.tmp speech.mp3
    echo "Success! Audio saved to speech.mp3"
else
    echo "ERROR! Server returned:"
    cat body.tmp
fi

rm -f headers.tmp body.tmp