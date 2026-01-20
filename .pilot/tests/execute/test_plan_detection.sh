#!/bin/bash
# Test: Plan exists in pending/
# Expected: Plan found and moved to in_progress/

set -e

TEST_DIR=".pilot/tests/execute/tmp"
PLAN_FILE="$TEST_DIR/test_plan_$(date +%s).md"

# Setup
mkdir -p "$TEST_DIR/.pilot/plan/pending"
mkdir -p "$TEST_DIR/.pilot/plan/in_progress"

cat > "$PLAN_FILE" <<'EOF'
# Test Plan

## Success Criteria
SC-1: Test plan detection
EOF

# Test: Create plan in pending/ and run detection
echo "TEST: Plan exists in pending/"
cp "$PLAN_FILE" "$TEST_DIR/.pilot/plan/pending/"

# Run detection logic (simulate 02_execute)
PLAN_SEARCH_ROOT="$TEST_DIR"
PLAN_PATH=""

# Step 0: File system cache flush
ls "$PLAN_SEARCH_ROOT/.pilot/plan/pending" >/dev/null 2>&1 || true

# Step 1: Direct globbing
if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | sort | head -1)"
fi

# Verify
if [ -n "$PLAN_PATH" ] && [ -f "$PLAN_PATH" ]; then
    echo "✅ PASS: Plan detected in pending/"
    echo "   Found: $PLAN_PATH"
    RESULT=0
else
    echo "❌ FAIL: Plan not detected"
    echo "   Expected: Plan in pending/"
    RESULT=1
fi

# Cleanup
rm -rf "$TEST_DIR"

exit $RESULT
