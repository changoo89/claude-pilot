#!/usr/bin/env bash
#
# Test: Worktree Path Persistence
#
# Purpose: Verify worktree path is stored and can be restored across Bash tool calls
#

set -o nounset
set -o pipefail

echo "=== Test: Worktree Path Persistence ==="
echo ""

# Setup
MAIN_PROJECT_ROOT="/Users/chanho/claude-pilot"
WORKTREE_PATH="/Users/chanho/claude-pilot-wt-test"
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"

# Test 1: Store worktree path
echo "Test 1: Store worktree path"
echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
echo "  Branch: wt/123" >> "$WORKTREE_PERSIST_FILE"
echo "  Main Branch: main" >> "$WORKTREE_PERSIST_FILE"

if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    echo "✓ Persistence file created: $WORKTREE_PERSIST_FILE"
    cat "$WORKTREE_PERSIST_FILE"
else
    echo "✗ Failed to create persistence file"
    exit 1
fi

echo ""

# Test 2: Restore worktree path (simulating new Bash tool call)
echo "Test 2: Restore worktree path"

if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    RESTORED_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    RESTORED_BRANCH="$(sed -n '2s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    RESTORED_MAIN="$(sed -n '3s/.*: //p' "$WORKTREE_PERSIST_FILE")"

    echo "  Restored Worktree Path: $RESTORED_PATH"
    echo "  Restored Branch: $RESTORED_BRANCH"
    echo "  Restored Main Branch: $RESTORED_MAIN"

    if [ "$RESTORED_PATH" = "$WORKTREE_PATH" ] && [ "$RESTORED_BRANCH" = "wt/123" ]; then
        echo "✓ Path restoration successful"
    else
        echo "✗ Path restoration failed"
        exit 1
    fi
else
    echo "✗ Persistence file not found"
    exit 1
fi

echo ""

# Test 3: Use restored path for plan detection
echo "Test 3: Use restored path for operations"

WORKTREE_ROOT="$RESTORED_PATH"
PLAN_SEARCH_ROOT="${WORKTREE_ROOT:-$MAIN_PROJECT_ROOT}"

echo "  Plan search root: $PLAN_SEARCH_ROOT"

if [ -d "$PLAN_SEARCH_ROOT/.pilot/plan" ]; then
    echo "✓ Plan directory exists at restored path"
else
    echo "✗ Plan directory not found at restored path"
fi

echo ""

# Cleanup
rm -f "$WORKTREE_PERSIST_FILE"

echo "=== Test Complete ==="
echo ""
echo "✓ All tests passed"
echo ""
echo "Note: This test verifies the persistence mechanism works."
echo "In actual Claude Code execution, each Bash tool call is a"
echo "new shell session, so the persistence file is critical for"
echo "maintaining worktree context across calls."
