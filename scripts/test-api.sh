#!/bin/bash

set -e

echo "======================================"
echo "LLM API Test Script"
echo "======================================"
echo ""

# Load environment variables
if [ -f .env ]; then
    source .env
fi

API_KEY=${LITELLM_MASTER_KEY:-sk-1234}
API_BASE=${API_BASE:-http://localhost:4000}

echo "Testing API at: $API_BASE"
echo "Using API Key: ${API_KEY:0:10}..."
echo ""

# Test health endpoint
echo "1. Testing health endpoint..."
curl -s "$API_BASE/health" | jq '.' 2>/dev/null || curl -s "$API_BASE/health"
echo ""
echo ""

# Test models endpoint
echo "2. Listing available models..."
curl -s -H "Authorization: Bearer $API_KEY" \
     "$API_BASE/v1/models" | jq '.' 2>/dev/null || curl -s -H "Authorization: Bearer $API_KEY" "$API_BASE/v1/models"
echo ""
echo ""

# Test chat completion
echo "3. Testing chat completion..."
echo "Prompt: 'Write a Python function to calculate fibonacci numbers'"
echo ""

RESPONSE=$(curl -s -X POST "$API_BASE/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "messages": [
      {
        "role": "user",
        "content": "Write a Python function to calculate fibonacci numbers. Keep it short."
      }
    ],
    "max_tokens": 500,
    "temperature": 0.7
  }')

echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""
echo ""

echo "======================================"
echo "API Test Complete!"
echo "======================================"
echo ""
echo "If you see responses above, your API is working correctly."
echo ""
echo "To test from VSCode Continue extension:"
echo "  1. Install the Continue extension"
echo "  2. Copy vscode-continue-config.json settings to Continue config"
echo "  3. Replace 'sk-1234-change-me-to-secure-key' with your API key: $API_KEY"
echo ""
