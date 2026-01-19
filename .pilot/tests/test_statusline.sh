#!/bin/bash
# Test statusline.sh draft count feature
# Tests TS-5, TS-6

set -euo pipefail

STATUSLINE_SCRIPT="/Users/chanho/claude-pilot/.claude/scripts/statusline.sh"

# Test setup
TEST_ROOT="/tmp/claude-pilot-test-$$"
PROJECT_ROOT="$TEST_ROOT/project"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

setup() {
    rm -rf "$TEST_ROOT"
    mkdir -p "$PROJECT_ROOT/.pilot/plan"/{pending,in_progress,draft}
}

# TS-5: Draft plans only
test_ts5_draft_only() {
    echo "TS-5: Draft plans only"
    setup

    # Create a draft plan
    echo "# Test Plan" > "$PROJECT_ROOT/.pilot/plan/draft/test_plan.md"

    # Create JSON input for statusline
    INPUT=$(cat <<EOF
{
  "model": {
    "display_name": "test-model"
  },
  "workspace": {
    "current_dir": "$PROJECT_ROOT"
  }
}
EOF
)

    OUTPUT=$(echo "$INPUT" | "$STATUSLINE_SCRIPT")
    echo "Output: $OUTPUT"

    # Should contain "D:1"
    [[ "$OUTPUT" == *"D:1"* ]] || { echo "FAIL: Expected D:1 in output"; return 1; }
    # Should contain "P:0" (no pending)
    [[ "$OUTPUT" == *"P:0"* ]] || { echo "FAIL: Expected P:0 in output"; return 1; }
    # Should contain "I:0" (no in_progress)
    [[ "$OUTPUT" == *"I:0"* ]] || { echo "FAIL: Expected I:0 in output"; return 1; }
    echo "PASS"
}

# TS-6: All states have plans
test_ts6_all_states() {
    echo "TS-6: All states have plans"
    setup

    # Create plans in all directories
    echo "# Draft 1" > "$PROJECT_ROOT/.pilot/plan/draft/draft1.md"
    echo "# Draft 2" > "$PROJECT_ROOT/.pilot/plan/draft/draft2.md"
    echo "# Pending 1" > "$PROJECT_ROOT/.pilot/plan/pending/pending1.md"
    echo "# In Progress 1" > "$PROJECT_ROOT/.pilot/plan/in_progress/inprogress1.md"

    # Create JSON input for statusline
    INPUT=$(cat <<EOF
{
  "model": {
    "display_name": "test-model"
  },
  "workspace": {
    "current_dir": "$PROJECT_ROOT"
  }
}
EOF
)

    OUTPUT=$(echo "$INPUT" | "$STATUSLINE_SCRIPT")
    echo "Output: $OUTPUT"

    # Should contain "D:2" (2 drafts)
    [[ "$OUTPUT" == *"D:2"* ]] || { echo "FAIL: Expected D:2 in output"; return 1; }
    # Should contain "P:1" (1 pending)
    [[ "$OUTPUT" == *"P:1"* ]] || { echo "FAIL: Expected P:1 in output"; return 1; }
    # Should contain "I:1" (1 in_progress)
    [[ "$OUTPUT" == *"I:1"* ]] || { echo "FAIL: Expected I:1 in output"; return 1; }
    echo "PASS"
}

# Run all tests
echo "=== Statusline Tests ==="
echo ""

test_ts5_draft_only
echo ""

test_ts6_all_states
echo ""

echo "=== All tests completed ==="
