#!/bin/bash

# Configuration
PROMPT="Two cats are playing together in a sunny garden, cinematic style"
OUT_PATH="cats_friends.mp4"
BASE_URL="${OPENAI_BASE_URL%/}"

# 1. Start render job (POST /videos)
echo "Starting video generation..."
RESPONSE=$(curl -s -X POST "$BASE_URL/videos" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"sora-2\",
    \"prompt\": \"$PROMPT\",
    \"seconds\": \"8\",
    \"size\": \"1280x720\"
  }")

# Extract Video ID and initial status
VIDEO_ID=$(echo "$RESPONSE" | jq -r '.id')
STATUS=$(echo "$RESPONSE" | jq -r '.status')

if [ "$VIDEO_ID" == "null" ]; then
    echo "Error starting job: $RESPONSE"
    exit 1
fi

echo "Video generation started. ID: $VIDEO_ID"

# 2. Poll status until done (GET /videos/{id})
while [[ "$STATUS" == "queued" || "$STATUS" == "in_progress" ]]; do
    PROGRESS=$(echo "$RESPONSE" | jq -r '.progress // 0')
    echo -ne "\rStatus: $STATUS ($PROGRESS%) - Waiting 10s..."
    
    sleep 10
    
    # Retrieve updated status
    RESPONSE=$(curl -s -X GET "$BASE_URL/videos/$VIDEO_ID" \
      -H "Authorization: Bearer $OPENAI_API_KEY")
    STATUS=$(echo "$RESPONSE" | jq -r '.status')
done

echo -e "\nFinal Status: $STATUS"

# 3. Check for failure
if [ "$STATUS" == "failed" ]; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // "Unknown error"')
    echo "Error: $ERROR_MSG"
    exit 1
fi

# 4. Download MP4 (GET /videos/{id}/content)
echo "Downloading video content..."
curl -s -L -X GET "$BASE_URL/videos/$VIDEO_ID/content?variant=video" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  --output "$OUT_PATH"

echo "Success: Wrote $(pwd)/$OUT_PATH"