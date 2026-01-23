#!/bin/bash
# Test: Skill documentation line count verification
# SC-1: vibe-coding/REFERENCE.md should be ≤300 lines

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
VIBE_REF="$PROJECT_ROOT/.claude/skills/vibe-coding/REFERENCE.md"

echo "Testing SC-1: vibe-coding/REFERENCE.md line count"

# Get line count
LINE_COUNT=$(wc -l < "$VIBE_REF" | tr -d ' ')

echo "Current line count: $LINE_COUNT"
echo "Target: ≤300 lines"

# Test condition
if [ "$LINE_COUNT" -le 300 ]; then
    echo "✅ PASS: Line count is $LINE_COUNT (≤300)"
    exit 0
else
    echo "❌ FAIL: Line count is $LINE_COUNT (>300)"
    exit 1
fi
