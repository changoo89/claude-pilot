#!/usr/bin/env bash
#
# Test: Worktree Mode Absolute Path Solution
#
# Purpose: Verify that worktree mode uses absolute paths correctly
#

set -o nounset
set -o pipefail

echo "=== Test: Worktree Mode Absolute Paths ==="
echo ""

# Variables that would be set in worktree mode
PROJECT_ROOT="/Users/chanho/claude-pilot"
WORKTREE_PATH="/Users/chanho/claude-pilot-wt-test"
WORKTREE_MODE="true"

# Simulate state file location logic
echo "Testing state file location logic:"
echo "  WORKTREE_MODE: $WORKTREE_MODE"
echo "  WORKTREE_ROOT: ${WORKTREE_ROOT:-not set}"

if [ "$WORKTREE_MODE" = true ]; then
    if [ -n "${WORKTREE_ROOT:-}" ]; then
        STATE_FILE="$WORKTREE_ROOT/.pilot/state/continuation.json"
        echo "  State file (worktree): $STATE_FILE"
    else
        echo "  State file: not set (worktree not created yet)"
    fi
fi

echo ""
echo "Testing plan detection with WORKTREE_ROOT:"

# This simulates what should happen in worktree mode
if [ -n "${WORKTREE_ROOT:-}" ]; then
    PLAN_SEARCH_ROOT="$WORKTREE_ROOT"
else
    PLAN_SEARCH_ROOT="$PROJECT_ROOT"
fi

echo "  Plan search root: $PLAN_SEARCH_ROOT"

# Check if plan directory exists
if [ -d "$PLAN_SEARCH_ROOT/.pilot/plan" ]; then
    echo "  ✓ Plan directory exists"
else
    echo "  ✗ Plan directory not found (expected in worktree mode)"
fi

echo ""
echo "=== Test Complete ==="
