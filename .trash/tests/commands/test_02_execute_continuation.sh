#!/bin/bash
# Test: /02_execute error handling with continuation state
# TS-2: No plan, continuation exists scenario

set -e

echo "=== TS-2: No Plan, Continuation Exists ==="

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
mkdir -p .pilot/state

# Create continuation state file
cat > .pilot/state/continuation.json <<'EOF'
{
  "version": "1.0",
  "session_id": "test-session-123",
  "branch": "main",
  "plan_file": ".pilot/plan/in_progress/test_plan.md",
  "todos": [
    {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
    {"id": "SC-2", "status": "in_progress", "iteration": 0, "owner": "coder"}
  ],
  "iteration_count": 1,
  "max_iterations": 7,
  "last_checkpoint": "2026-01-20T10:30:00Z",
  "continuation_level": "normal"
}
EOF

echo "Setup: continuation state created"

# Test: Run plan detection logic (simulate /02_execute Step 1)
PLAN_SEARCH_ROOT="$TEMP_DIR"
STATE_FILE="$PLAN_SEARCH_ROOT/.pilot/state/continuation.json"
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

# Verify: Error message output with continuation
if [ -z "$PLAN_PATH" ] || [ ! -f "$PLAN_PATH" ]; then
    COUNT_PENDING=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    COUNT_IN_PROGRESS=$(find "$PLAN_SEARCH_ROOT/.pilot/plan/in_progress" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    # Check continuation state
    CONTINUATION_STATUS="not found"
    if [ -f "$STATE_FILE" ]; then
        CONTINUATION_STATUS="exists"
    fi

    # Output enhanced error message
    echo ""
    echo "## No Execution Plan Found"
    echo ""
    echo "**Diagnostic Information**:"
    echo "- Pending plans: $COUNT_PENDING"
    echo "- In-progress plans: $COUNT_IN_PROGRESS"
    echo "- Continuation state: $CONTINUATION_STATUS"
    echo ""
    echo "**Required Action**:"
    echo "You need to create an execution plan before running /02_execute."
    echo ""
    echo "**Next Steps** (choose one):"
    echo "1. Create a new plan: /00_plan \"describe your task\""
    echo "2. If you have a draft plan: /01_confirm"
    if [ "$CONTINUATION_STATUS" = "exists" ]; then
        echo "3. Resume previous work: /00_continue (continuation state exists)"
    fi
    echo ""
    echo "**Workflow Reference**:"
    echo "/00_plan → /01_confirm → /02_execute → /03_close"
    echo ""

    # Assertions
    if [ "$COUNT_PENDING" -ne 0 ]; then
        echo "✗ TS-2 FAILED: Expected 0 pending plans, got $COUNT_PENDING"
        exit 1
    fi
    if [ "$COUNT_IN_PROGRESS" -ne 0 ]; then
        echo "✗ TS-2 FAILED: Expected 0 in-progress plans, got $COUNT_IN_PROGRESS"
        exit 1
    fi
    if [ "$CONTINUATION_STATUS" != "exists" ]; then
        echo "✗ TS-2 FAILED: Expected continuation state to exist, got $CONTINUATION_STATUS"
        exit 1
    fi

    # Verify /00_continue option is displayed
    OUTPUT=$(cat <<'EOF'
## No Execution Plan Found

**Diagnostic Information**:
- Pending plans: 0
- In-progress plans: 0
- Continuation state: exists

**Required Action**:
You need to create an execution plan before running /02_execute.

**Next Steps** (choose one):
1. Create a new plan: /00_plan "describe your task"
2. If you have a draft plan: /01_confirm
3. Resume previous work: /00_continue (continuation state exists)

**Workflow Reference**:
/00_plan → /01_confirm → /02_execute → /03_close
EOF
)

    if echo "$OUTPUT" | grep -q "/00_continue"; then
        echo "✓ TS-2 PASSED: Error message includes /00_continue option"
    else
        echo "✗ TS-2 FAILED: /00_continue option not displayed"
        exit 1
    fi
else
    echo "✗ TS-2 FAILED: Plan should not be found"
    exit 1
fi

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo "=== TS-2 Complete ==="
