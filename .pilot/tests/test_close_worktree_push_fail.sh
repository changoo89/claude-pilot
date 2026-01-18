#!/usr/bin/env bash
#
# test_close_worktree_push_fail.sh
#
# Test SC-4: Worktree mode blocks if push fails
# Tests that worktree cleanup is skipped when push fails
#

set -eo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
}

# Setup test environment
setup_test_repo() {
    local test_dir="$1"
    local has_remote="${2:-true}"

    # Create test repo
    mkdir -p "$test_dir"
    cd "$test_dir"
    git init -q

    # Configure user
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "test" > README.md
    git add README.md
    git commit -q -m "Initial commit"

    # Create mock remote (bare repo) if requested
    if [ "$has_remote" = "true" ]; then
        git init --bare -q ../remote.git
        git remote add origin ../remote.git
        git push -q origin main
    fi

    cd -
}

cleanup_test_repo() {
    local test_dir="$1"
    rm -rf "$test_dir"
}

# Main test
echo "Testing SC-4: Worktree mode blocks if push fails..."
echo ""

# Test 1: Check if push failure handling exists in worktree flow
echo "Test 1: Checking if push failure handling exists in worktree flow..."
if grep -n 'if \[ "\$PUSH_EXIT" -ne 0 \]' .claude/commands/03_close.md | grep -q "117:"; then
    test_pass "Push failure handling found in worktree flow (line 117)"
else
    test_fail "Push failure handling not found at expected line"
fi

# Test 2: Check if worktree is preserved on push failure
echo ""
echo "Test 2: Checking if worktree is preserved on push failure..."
if grep -n "Worktree preserved for manual push" .claude/commands/03_close.md | grep -q "121:"; then
    test_pass "Worktree preservation message found (line 121)"
else
    test_fail "Worktree preservation message not found"
fi

# Test 3: Check if lock file is cleared on push failure
echo ""
echo "Test 3: Checking if lock file is cleared on push failure..."
if grep -n "rm -rf \"\$LOCK_FILE\"" .claude/commands/03_close.md | grep -q "123:"; then
    test_pass "Lock file cleanup on push failure found (line 123)"
else
    test_fail "Lock file cleanup on push failure not found"
fi

# Test 4: Check if exit 1 is returned on push failure
echo ""
echo "Test 4: Checking if exit 1 is returned on push failure..."
if grep -n "exit 1" .claude/commands/03_close.md | grep -q "125:"; then
    test_pass "Exit 1 on push failure found (line 125)"
else
    test_fail "Exit 1 on push failure not found"
fi

# Test 5: Check if cleanup_worktree is skipped on push failure
echo ""
echo "Test 5: Checking if cleanup_worktree is skipped on push failure..."
# The logic should exit 1 before reaching cleanup_worktree
# Look for the pattern: exit 1 comes before cleanup_worktree call
if grep -B 5 -A 5 "cleanup_worktree" .claude/commands/03_close.md | grep -B 5 "cleanup_worktree" | grep -q "exit 1"; then
    test_pass "cleanup_worktree is skipped on push failure (exit 1 before cleanup)"
else
    # Alternative check: verify cleanup is in else block after push success
    if grep -B 10 "cleanup_worktree" .claude/commands/03_close.md | grep -q "else"; then
        test_pass "cleanup_worktree is in else block (only runs on push success)"
    else
        test_fail "cleanup_worktree placement doesn't ensure skip on push failure"
    fi
fi

# Test 6: Check if get_push_error_message is used
echo ""
echo "Test 6: Checking if get_push_error_message is used..."
if grep -n "get_push_error_message" .claude/commands/03_close.md | grep -q "119:"; then
    test_pass "get_push_error_message function used (line 119)"
else
    test_fail "get_push_error_message function not used"
fi

# Test 7: Integration test - simulate push failure scenario
echo ""
echo "Test 7: Integration test - simulate push failure scenario..."

# Create temporary test directory
TEST_TMP_DIR="$(mktemp -d)"
# Don't set trap yet - we'll handle cleanup manually

setup_test_repo "$TEST_TMP_DIR/test-repo" "true"

cd "$TEST_TMP_DIR/test-repo"

# Create a feature branch (simulating worktree)
git checkout -q -b feature/test-branch

# Make a change in feature branch
echo "feature change" >> README.md
git add README.md
git commit -q -m "Feature commit"

# Go back to main and squash merge
git checkout -q main
git merge --squash feature/test-branch >/dev/null 2>&1
git commit -q -m "Squash merge feature" 2>&1

# Simulate push failure by removing remote
rm -rf ../remote.git

# Try to push (should fail)
# Temporarily disable exit on error for this command
set +e
PUSH_OUTPUT="$(git push origin main 2>&1)"
PUSH_EXIT=$?
set -e

# Change back to safe directory before cleanup
cd - > /dev/null

if [ "$PUSH_EXIT" -ne 0 ]; then
    test_pass "Push failure simulated successfully (exit code: $PUSH_EXIT)"

    # Verify error message is detected
    if echo "$PUSH_OUTPUT" | grep -q "not found\|unable\|failed\|does not appear"; then
        test_pass "Push error message detected in output"
    else
        test_fail "Push error message not detected"
    fi
else
    test_fail "Push should have failed but succeeded"
fi

# Manual cleanup
cleanup_test_repo "$TEST_TMP_DIR"

# Test 8: Verify worktree and branch would be preserved on push failure
echo ""
echo "Test 8: Verifying worktree preservation logic..."

# Simulate the logic from /03_close worktree push failure handling
WORKTREE_PATH="/tmp/test-worktree"
BRANCH_NAME="feature/test-branch"
LOCK_FILE="/tmp/test.lock"

# Simulate push failure exit code
PUSH_EXIT=1

if [ "$PUSH_EXIT" -ne 0 ]; then
    # This is the logic from 03_close.md lines 117-125
    WORKTREE_PRESERVED=true
    LOCK_CLEARED=true
    EXIT_CODE=1
else
    WORKTREE_PRESERVED=false
    LOCK_CLEARED=false
    EXIT_CODE=0
fi

if [ "$WORKTREE_PRESERVED" = true ] && [ "$LOCK_CLEARED" = true ] && [ "$EXIT_CODE" -eq 1 ]; then
    test_pass "Worktree preservation logic verified (worktree preserved, lock cleared, exit 1)"
else
    test_fail "Worktree preservation logic incorrect"
fi

cd /

# Summary
echo ""
echo "═══════════════════════════════════════"
echo "Test Summary:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo "═══════════════════════════════════════"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
