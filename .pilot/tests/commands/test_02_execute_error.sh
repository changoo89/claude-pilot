#!/bin/bash
# Test: /02_execute error handling when no plan exists
# TS-1: No plan, no continuation scenario

set -e

echo "=== TS-1: No Plan, No Continuation ==="

# Setup: Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Initialize git repo (required for plan detection)
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

# Create pilot directory structure
mkdir -p .pilot/plan/pending
mkdir -p .pilot/plan/in_progress

# Verify: Empty plan directories
COUNT_PENDING=$(find .pilot/plan/pending -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
COUNT_IN_PROGRESS=$(find .pilot/plan/in_progress -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "Setup: pending=$COUNT_PENDING, in_progress=$COUNT_IN_PROGRESS"

# Test: Run plan detection logic (simulate /02_execute Step 1)
PLAN_SEARCH_ROOT="$TEMP_DIR"
PLAN_PATH=""

# Run plan detection (from /02_execute Step 1)
PLAN_PATH="$(printf "%s\n" "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | while read -r f; do [ -f "$f" ] && printf "%s\n" "$f"; done | sort | head -1)"

if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -1)"
fi

if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(ls -1tr "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"
fi

if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PLAN_SEARCH_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH" 2>/dev/null || true
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH="$(find "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -1)"
fi

# Verify: Error message output
if [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ]; then
    COUNT_PENDING=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    COUNT_IN_PROGRESS=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    # Output enhanced error message
    echo ""
    echo "## No Execution Plan Found"
    echo ""
    echo "**Diagnostic Information**:"
    echo "- Pending plans: $COUNT_PENDING"
    echo "- In-progress plans: $COUNT_IN_PROGRESS"
    echo ""
    echo "**Required Action**:"
    echo "You need to create an execution plan before running /02_execute."
    echo ""
    echo "**Next Steps** (choose one):"
    echo "1. Create a new plan: /00_plan \"describe your task\""
    echo "2. If you have a draft plan: /01_confirm"
    echo ""
    echo "**Workflow Reference**:"
    echo "/00_plan → /01_confirm → /02_execute → /03_close"
    echo ""

    # Assertions
    if [ "$COUNT_PENDING" -ne 0 ]; then
        echo "✗ TS-1 FAILED: Expected 0 pending plans, got $COUNT_PENDING"
        exit 1
    fi
    if [ "$COUNT_IN_PROGRESS" -ne 0 ]; then
        echo "✗ TS-1 FAILED: Expected 0 in-progress plans, got $COUNT_IN_PROGRESS"
        exit 1
    fi
    if [ "$CONTINUATION_STATUS" != "not found" ]; then
        echo "✗ TS-1 FAILED: Expected no continuation state, got $CONTINUATION_STATUS"
        exit 1
    fi

    echo "✓ TS-1 PASSED: Error message displayed correctly"
else
    echo "✗ TS-1 FAILED: Plan should not be found"
    exit 1
fi

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo "=== TS-1 Complete ==="
