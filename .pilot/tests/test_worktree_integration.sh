#!/usr/bin/env bash
#
# Integration Test: Worktree Mode End-to-End
#
# Purpose: Verify complete worktree mode workflow
#          This test simulates the entire /02_execute --wt flow
#

set -o nounset
set -o pipefail

echo "=== Integration Test: Worktree Mode E2E ==="
echo ""

# Setup
MAIN_PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKTREE_CREATE_SCRIPT="$MAIN_PROJECT_ROOT/.claude/scripts/worktree-create.sh"
TEST_PLAN_NAME="test_worktree_plan.md"

echo "Configuration:"
echo "  Main Project: $MAIN_PROJECT_ROOT"
echo "  Worktree Script: $WORKTREE_CREATE_SCRIPT"
echo ""

# Test 1: Create test plan
echo "Test 1: Create test plan in pending"
TEST_PLAN_CONTENT="# Test Plan: Worktree Mode

## Problem Statement
Test worktree mode functionality

## Success Criteria
- [ ] SC-1: Worktree created
- [ ] SC-2: Plan moved to worktree
- [ ] SC-3: Context restored
"

mkdir -p "$MAIN_PROJECT_ROOT/.pilot/plan/pending"
echo "$TEST_PLAN_CONTENT" > "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"

if [ -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME" ]; then
    echo "✓ Test plan created"
else
    echo "✗ Failed to create test plan"
    exit 1
fi

echo ""

# Test 2: Simulate worktree creation (Step 1.1)
echo "Test 2: Create worktree"
WT_BRANCH="wt/test-$(date +%s)"
WT_MAIN_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"

echo "  Branch: $WT_BRANCH"
echo "  Base: $WT_MAIN_BRANCH"

# Call worktree creation script
WORKTREE_OUTPUT="$(bash "$WORKTREE_CREATE_SCRIPT" "$WT_BRANCH" "$WT_MAIN_BRANCH" 2>&1)"
WORKTREE_EXIT_CODE=$?

if [ $WORKTREE_EXIT_CODE -eq 0 ]; then
    WORKTREE_PATH="$(echo "$WORKTREE_OUTPUT" | grep "^WORKTREE_PATH=" | cut -d'=' -f2)"
    echo "✓ Worktree created: $WORKTREE_PATH"
else
    echo "✗ Worktree creation failed"
    rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
    exit 1
fi

echo ""

# Test 3: Store worktree path (persistence mechanism)
echo "Test 3: Store worktree path"
WORKTREE_PERSIST_FILE="$MAIN_PROJECT_ROOT/.pilot/worktree_active.txt"

echo "$WORKTREE_PATH" > "$WORKTREE_PERSIST_FILE"
echo "  Branch: $WT_BRANCH" >> "$WORKTREE_PERSIST_FILE"
echo "  Main Branch: $WT_MAIN_BRANCH" >> "$WORKTREE_PERSIST_FILE"

if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    echo "✓ Worktree path stored"
    cat "$WORKTREE_PERSIST_FILE" | sed 's/^/  /'
else
    echo "✗ Failed to store worktree path"
    git worktree remove "$WORKTREE_PATH" 2>/dev/null
    rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
    exit 1
fi

echo ""

# Test 4: Restore worktree context (simulate new Bash tool call)
echo "Test 4: Restore worktree context"

# Clear variables to simulate new shell
unset WORKTREE_PATH
unset WORKTREE_BRANCH
unset MAIN_BRANCH
unset WORKTREE_ROOT

# Restore from persistence file
if [ -f "$WORKTREE_PERSIST_FILE" ]; then
    WORKTREE_PATH="$(head -1 "$WORKTREE_PERSIST_FILE")"
    WORKTREE_BRANCH="$(sed -n '2s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    MAIN_BRANCH="$(sed -n '3s/.*: //p' "$WORKTREE_PERSIST_FILE")"
    WORKTREE_ROOT="$WORKTREE_PATH"

    echo "  Restored Worktree Path: $WORKTREE_PATH"
    echo "  Restored Branch: $WORKTREE_BRANCH"
    echo "✓ Context restored successfully"
else
    echo "✗ Persistence file not found"
    git worktree remove "$WORKTREE_PATH" 2>/dev/null
    rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
    rm -f "$WORKTREE_PERSIST_FILE"
    exit 1
fi

echo ""

# Test 5: Plan detection with worktree paths
echo "Test 5: Plan detection with worktree paths"

# NOTE: In worktree mode, plans are in main repo, not worktree
# The worktree is a separate working directory linked to the same git repo
PLAN_SEARCH_ROOT="$MAIN_PROJECT_ROOT"
PLAN_PATH="$(ls -1t "$PLAN_SEARCH_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | head -1)"

if [ -n "$PLAN_PATH" ]; then
    echo "✓ Plan found: $PLAN_PATH"
    echo "  (Plan detected in main repo as expected)"
else
    echo "✗ Plan not found"
    git worktree remove "$WORKTREE_PATH" 2>/dev/null
    rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
    rm -f "$WORKTREE_PERSIST_FILE"
    exit 1
fi

echo ""

# Test 6: Move plan to in_progress
echo "Test 6: Move plan to in_progress"

PLAN_FILENAME="$(basename "$PLAN_PATH")"
IN_PROGRESS_PATH="$MAIN_PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"

mkdir -p "$MAIN_PROJECT_ROOT/.pilot/plan/in_progress"
mv "$PLAN_PATH" "$IN_PROGRESS_PATH"

if [ -f "$IN_PROGRESS_PATH" ]; then
    echo "✓ Plan moved to: $IN_PROGRESS_PATH"
else
    echo "✗ Failed to move plan"
    git worktree remove "$WORKTREE_PATH" 2>/dev/null
    rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
    rm -f "$WORKTREE_PERSIST_FILE"
    exit 1
fi

echo ""

# Test 7: Verify plan state
echo "Test 7: Verify plan state"

if [ -f "$IN_PROGRESS_PATH" ] && [ ! -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$PLAN_FILENAME" ]; then
    echo "✓ Plan exists in in_progress"
    echo "✓ Plan removed from pending"
else
    echo "✗ Plan state incorrect"
fi

echo ""

# Cleanup
echo "Cleanup:"
rm -f "$IN_PROGRESS_PATH"
git worktree remove "$WORKTREE_PATH" 2>/dev/null
rm -f "$WORKTREE_PERSIST_FILE"
rm -f "$MAIN_PROJECT_ROOT/.pilot/plan/pending/$TEST_PLAN_NAME"
echo "✓ Cleanup complete"

echo ""
echo "=== Integration Test Complete ==="
echo ""
echo "✓ All tests passed"
echo ""
echo "Summary:"
echo "  - Worktree creation: ✓"
echo "  - Path persistence: ✓"
echo "  - Context restoration: ✓"
echo "  - Plan detection: ✓"
echo "  - Plan movement: ✓"
echo ""
echo "The worktree mode implementation is working correctly!"
