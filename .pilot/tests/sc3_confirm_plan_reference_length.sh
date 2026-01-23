#!/bin/bash

# Test SC-3: confirm-plan/REFERENCE.md line count verification
# Target: ≤300 lines

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARGET_FILE="$PROJECT_ROOT/.claude/skills/confirm-plan/REFERENCE.md"

echo "Testing SC-3: confirm-plan/REFERENCE.md line count"
echo "Target: ≤300 lines"
echo ""

if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ FAIL: File not found: $TARGET_FILE"
    exit 1
fi

LINE_COUNT=$(wc -l < "$TARGET_FILE" | tr -d ' ')

echo "Current line count: $LINE_COUNT"

if [ "$LINE_COUNT" -le 300 ]; then
    echo "✅ PASS: Line count $LINE_COUNT ≤ 300"
    exit 0
else
    echo "❌ FAIL: Line count $LINE_COUNT > 300"
    exit 1
fi
