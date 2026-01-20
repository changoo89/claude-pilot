#!/bin/bash
# Test: In-progress plan exists
# Expected: In-progress plan selected when no pending plans

set -e

TEST_DIR=".pilot/tests/execute/tmp"

# Setup
mkdir -p "$TEST_DIR/.pilot/plan/pending"
mkdir -p "$TEST_DIR/.pilot/plan/in_progress"

# Test: In-progress plan exists
echo "TEST: In-progress plan selection"

PLAN_FILE="$TEST_DIR/.pilot/plan/in_progress/existing_plan.md"
cat > "$PLAN_FILE" <<EOF
# Existing In-Progress Plan
EOF

# Run detection logic
PLAN_SEARCH_ROOT="$TEST_DIR"
PLAN_PATH=""

# Pending check (should be empty)
ls "$PLAN_SEARCH_ROOT/.pilot/plan/pending" >/dev/null 2>&1 || true

if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | sort | head -1)"
fi

# Fallback to in_progress
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -1)"
fi

# Verify
if [ -n "$PLAN_PATH" ] && [ -f "$PLAN_PATH" ]; then
    PLAN_NAME="$(basename "$PLAN_PATH")"
    if [ "$PLAN_NAME" = "existing_plan.md" ]; then
        echo "✅ PASS: In-progress plan selected"
        echo "   Selected: $PLAN_PATH"
        RESULT=0
    else
        echo "❌ FAIL: Wrong plan selected"
        echo "   Expected: existing_plan.md, Got: $PLAN_NAME"
        RESULT=1
    fi
else
    echo "❌ FAIL: No plan detected"
    RESULT=1
fi

# Cleanup
rm -rf "$TEST_DIR"

exit $RESULT
