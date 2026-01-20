#!/bin/bash
# Test: File system sync edge case
# Expected: Plan detected reliably immediately after creation

set -e

TEST_DIR=".pilot/tests/execute/tmp"

# Setup
mkdir -p "$TEST_DIR/.pilot/plan/pending"
mkdir -p "$TEST_DIR/.pilot/plan/in_progress"

# Test: Create plan and immediately detect
echo "TEST: File system sync edge case"

PLAN_FILE="$TEST_DIR/.pilot/plan/pending/test_sync_$(date +%s%N).md"
cat > "$PLAN_FILE" <<EOF
# Sync Test Plan
EOF

# Immediate detection (simulate race condition)
PLAN_SEARCH_ROOT="$TEST_DIR"
PLAN_PATH=""

# Critical: ls cache flush happens here
ls "$PLAN_SEARCH_ROOT/.pilot/plan/pending" >/dev/null 2>&1 || true

# Method 1: Direct globbing
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | sort | head -1)"
fi

# Verify
if [ -n "$PLAN_PATH" ] && [ -f "$PLAN_PATH" ]; then
    echo "✅ PASS: Plan detected immediately after creation"
    echo "   Found: $PLAN_PATH"
    RESULT=0
else
    echo "❌ FAIL: Plan not detected immediately"
    echo "   File exists: $([ -f "$PLAN_FILE" ] && echo "YES" || echo "NO")"
    RESULT=1
fi

# Cleanup
rm -rf "$TEST_DIR"

exit $RESULT
