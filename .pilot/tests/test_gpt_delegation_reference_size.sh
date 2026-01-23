#!/bin/bash

# Test: GPT Delegation REFERENCE.md line count

REFERENCE_FILE=".claude/skills/gpt-delegation/REFERENCE.md"
MAX_LINES=300

# Count lines
line_count=$(wc -l < "$REFERENCE_FILE")

echo "GPT Delegation REFERENCE.md line count: $line_count (max: $MAX_LINES)"

if [ "$line_count" -le "$MAX_LINES" ]; then
  echo "✅ PASS: Line count within limit"
  exit 0
else
  echo "❌ FAIL: Line count exceeds limit by $((line_count - MAX_LINES)) lines"
  exit 1
fi
