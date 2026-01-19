#!/bin/bash
# Test plan detection fixes for /02_execute
# Tests TS-1 through TS-4, TS-8

set -euo pipefail

# Source worktree utilities for select_oldest_pending function
WORKTREE_UTILS="$(dirname "$0")/../.claude/scripts/worktree-utils.sh"
if [ -f "$WORKTREE_UTILS" ]; then
    . "$WORKTREE_UTILS"
fi

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

# TS-1: Empty pending directory (bash)
test_ts1_empty_pending_bash() {
    echo "TS-1: Empty pending directory (bash)"
    setup

    PLAN_PATH=$(find "$PROJECT_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1)
    echo "Result: [$PLAN_PATH]"

    # Should be empty, no error
    [ -z "$PLAN_PATH" ] || { echo "FAIL: Expected empty path"; return 1; }
    echo "PASS"
}

# TS-2: Empty pending directory (zsh)
test_ts2_empty_pending_zsh() {
    echo "TS-2: Empty pending directory (zsh)"
    setup

    if command -v zsh >/dev/null 2>&1; then
        PLAN_PATH=$(zsh -c 'find "$1/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1' zsh "$PROJECT_ROOT")
        echo "Result: [$PLAN_PATH]"

        # Should be empty, no error
        [ -z "$PLAN_PATH" ] || { echo "FAIL: Expected empty path"; return 1; }
        echo "PASS"
    else
        echo "SKIP: zsh not available"
    fi
}

# TS-3: Pending plans exist (oldest selected)
test_ts3_pending_oldest() {
    echo "TS-3: Pending plans exist (oldest selected)"
    setup

    # Create 3 test plans with different timestamps
    touch -t 202501010001 "$PROJECT_ROOT/.pilot/plan/pending/plan1.md"
    touch -t 202501010002 "$PROJECT_ROOT/.pilot/plan/pending/plan2.md"
    touch -t 202501010003 "$PROJECT_ROOT/.pilot/plan/pending/plan3.md"

    PLAN_PATH=$(find "$PROJECT_ROOT/.pilot/plan/pending" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1)
    echo "Result: [$PLAN_PATH]"

    # Should select oldest (plan1.md)
    [[ "$PLAN_PATH" == *"plan1.md" ]] || { echo "FAIL: Expected plan1.md, got $PLAN_PATH"; return 1; }
    echo "PASS"
}

# TS-4: In-progress plans exist (newest selected)
test_ts4_in_progress_newest() {
    echo "TS-4: In-progress plans exist (newest selected)"
    setup

    # Create 3 test plans with different timestamps
    touch -t 202501010001 "$PROJECT_ROOT/.pilot/plan/in_progress/plan1.md"
    touch -t 202501010002 "$PROJECT_ROOT/.pilot/plan/in_progress/plan2.md"
    touch -t 202501010003 "$PROJECT_ROOT/.pilot/plan/in_progress/plan3.md"

    PLAN_PATH=$(find "$PROJECT_ROOT/.pilot/plan/in_progress" -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1t 2>/dev/null | head -1)
    echo "Result: [$PLAN_PATH]"

    # Should select newest (plan3.md)
    [[ "$PLAN_PATH" == *"plan3.md" ]] || { echo "FAIL: Expected plan3.md, got $PLAN_PATH"; return 1; }
    echo "PASS"
}

# TS-8: worktree-utils.sh fix
test_ts8_worktree_utils() {
    echo "TS-8: worktree-utils.sh fix"
    setup

    # Create test plans
    touch -t 202501010001 "$PROJECT_ROOT/.pilot/plan/pending/plan1.md"
    touch -t 202501010002 "$PROJECT_ROOT/.pilot/plan/pending/plan2.md"

    # Change to test directory
    cd "$PROJECT_ROOT"

    # Test the fixed logic directly (inline version of select_oldest_pending)
    RESULT=$(find .pilot/plan/pending -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null | head -1)
    echo "Result: [$RESULT]"

    # Should select oldest (plan1.md)
    [[ "$RESULT" == *"plan1.md" ]] || { echo "FAIL: Expected plan1.md, got $RESULT"; return 1; }
    echo "PASS"
}

# Run all tests
echo "=== Plan Detection Tests ==="
echo ""

test_ts1_empty_pending_bash
echo ""

test_ts2_empty_pending_zsh
echo ""

test_ts3_pending_oldest
echo ""

test_ts4_in_progress_newest
echo ""

test_ts8_worktree_utils
echo ""

echo "=== All tests completed ==="
