#!/bin/bash

SUB_PATH=/v1/messages
LLM_URL=$ANTHROPIC_BASE_URL$SUB_PATH

curl -X POST $LLM_URL -H "Authorization: Bearer $ANTHROPIC_API_KEY" -H "Content-Type: application/json" -H "anthropic-version: 2023-06-01" -d '{"max_tokens": 500, "model": "claude-sonnet-4-5", "messages": [ { "role": "user", "content": "'"$CODIO_FREE_TEXT_ANSWER"'" } ] }'
