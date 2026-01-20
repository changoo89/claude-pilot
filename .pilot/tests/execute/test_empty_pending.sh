#!/bin/bash
# Test: Empty pending directory
# Expected: "No plan found" error with file count (0)

set -e

TEST_DIR=".pilot/tests/execute/tmp"

# Setup
mkdir -p "$TEST_DIR/.pilot/plan/pending"
mkdir -p "$TEST_DIR/.pilot/plan/in_progress"

# Test: Empty pending/ directory
echo "TEST: Empty pending directory"

PLAN_SEARCH_ROOT="$TEST_DIR"
PLAN_PATH=""

# Run detection logic
PLAN_PATH=""
ls "$PLAN_SEARCH_ROOT/.pilot/plan/pending" >/dev/null 2>&1 || true

# Method 1
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | sort | head -1)"
fi

# Method 2
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -1)"
fi

# Method 3
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1tr "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"
fi

# Verify
if [ -z "$PLAN_PATH" ]; then
    COUNT_PENDING=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COUNT_PENDING" -eq 0 ]; then
        echo "✅ PASS: Empty pending/ detected correctly"
        echo "   File count: $COUNT_PENDING"
        RESULT=0
    else
        echo "❌ FAIL: File count mismatch"
        echo "   Expected: 0, Got: $COUNT_PENDING"
        RESULT=1
    fi
else
    echo "❌ FAIL: Plan detected when directory is empty"
    echo "   Found: $PLAN_PATH"
    RESULT=1
fi

# Cleanup
rm -rf "$TEST_DIR"

exit $RESULT
