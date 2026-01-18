#!/usr/bin/env bash

# Test: CLAUDE.md length verification
# Success Criteria: CLAUDE.md must be < 300 lines

set -euo pipefail

FILE_PATH="/Users/chanho/claude-pilot/CLAUDE.md"
MAX_LINES=300

echo "=== Test: CLAUDE.md Length Verification ==="
echo "File: $FILE_PATH"
echo "Max allowed lines: $MAX_LINES"
echo ""

# Count lines
LINE_COUNT=$(wc -l < "$FILE_PATH")
echo "Actual line count: $LINE_COUNT"

# Verify
if [ "$LINE_COUNT" -lt "$MAX_LINES" ]; then
    echo "✅ PASS: CLAUDE.md has $LINE_COUNT lines (< $MAX_LINES)"
    exit 0
else
    echo "❌ FAIL: CLAUDE.md has $LINE_COUNT lines (>= $MAX_LINES)"
    exit 1
fi
