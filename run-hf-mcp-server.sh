#!/usr/bin/env bash

# Usage: ./run-hf-mcp-server.sh <YOUR_HF_TOKEN>

if [ -z "$1" ]; then
  echo "Usage: $0 <YOUR_HF_TOKEN>"
  exit 1
fi

HF_TOKEN="$1"

npx mcp-remote https://huggingface.co/mcp --header "Authorization: Bearer $HF_TOKEN"