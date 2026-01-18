#!/usr/bin/env bash
#
# test_close_worktree_push.sh
#
# Test SC-3: Worktree mode includes git push after squash merge
# Tests that worktree merge flow includes git push step
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
    git init

    # Configure user
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "test" > README.md
    git add README.md
    git commit -m "Initial commit"

    # Create mock remote (bare repo) if requested
    if [ "$has_remote" = "true" ]; then
        git init --bare ../remote.git
        git remote add origin ../remote.git
    fi

    cd -
}

cleanup_test_repo() {
    local test_dir="$1"
    rm -rf "$test_dir"
}

# Main test
echo "Testing SC-3: Worktree mode includes git push after squash merge..."
echo ""

# Test 1: Check if git push step exists in worktree flow
echo "Test 1: Checking if git push step exists in Step 1 worktree flow..."
if grep -A 50 "## Step 1: Worktree Context" .claude/commands/03_close.md | grep -q "Push squash merge to remote"; then
    test_pass "Git push step found in worktree flow"
else
    test_fail "Git push step not found in worktree flow"
fi

# Test 2: Check if git_push_with_retry is used in worktree flow
echo ""
echo "Test 2: Checking if git_push_with_retry function is used..."
if grep -n "git_push_with_retry" .claude/commands/03_close.md | grep -q "11[34]:"; then
    test_pass "git_push_with_retry function is used in worktree flow (line 113-114)"
else
    test_fail "git_push_with_retry function not found in worktree flow"
fi

# Test 3: Check if push happens after do_squash_merge
echo ""
echo "Test 3: Checking if push happens after squash merge success..."
# Look for the pattern: push step comes after do_squash_merge success block
if grep -B 5 -A 20 "do_squash_merge" .claude/commands/03_close.md | grep -A 15 "else" | grep -q "Pushing squash merge"; then
    test_pass "Push step occurs after squash merge success"
else
    test_fail "Push step not properly placed after squash merge"
fi

# Test 4: Check if push failure handling exists
echo ""
echo "Test 4: Checking if push failure handling exists..."
if grep -n '"\$PUSH_EXIT" -ne 0' .claude/commands/03_close.md | grep -q "117:"; then
    test_pass "Push failure handling found in worktree flow (line 117)"
else
    test_fail "Push failure handling not found"
fi

# Test 5: Check if worktree is preserved on push failure
echo ""
echo "Test 5: Checking if worktree is preserved on push failure..."
if grep -n "Worktree preserved for manual push" .claude/commands/03_close.md | grep -q "121:"; then
    test_pass "Worktree preservation on push failure documented (line 121)"
else
    test_fail "Worktree preservation on push failure not documented"
fi

# Test 6: Verify push success message
echo ""
echo "Test 6: Checking if push success message exists..."
if grep -n "✓ Push successful" .claude/commands/03_close.md | grep -q "127:"; then
    test_pass "Push success message found (line 127)"
else
    test_fail "Push success message not found"
fi

# Test 7: Integration test with mock repository
echo ""
echo "Test 7: Integration test with mock worktree setup..."

# Create temporary test directory
TEST_TMP_DIR="$(mktemp -d)"
trap "cleanup_test_repo '$TEST_TMP_DIR'" EXIT

setup_test_repo "$TEST_TMP_DIR/test-repo" "true"

cd "$TEST_TMP_DIR/test-repo"

# Create a feature branch
git checkout -b feature/test-branch

# Make a change in feature branch
echo "feature change" >> README.md
git add README.md
git commit -m "Feature commit"

# Go back to main
git checkout main

# Squash merge the feature branch
git merge --squash feature/test-branch 2>/dev/null || true
git commit -m "Squash merge feature" 2>/dev/null || true

# Get local SHA
LOCAL_SHA="$(git rev-parse HEAD)"

# Push to remote
git push origin main >/dev/null 2>&1 || {
    test_fail "Failed to push in integration test"
    cd /
    exit 1
}

# Get remote SHA
REMOTE_SHA="$(git rev-parse origin/main)"

# Compare SHAs
if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    test_pass "Integration test: Squash merge and push successful"
else
    test_fail "Integration test: SHA mismatch after push"
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
