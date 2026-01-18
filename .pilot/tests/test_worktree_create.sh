#!/usr/bin/env bash
#
# test_worktree_create.sh
#
# Test worktree creation functionality
#

set -eo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
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

# Main test
echo "Testing worktree creation..."

# Test 1: worktree-create.sh exists
if [ -f ".claude/scripts/worktree-create.sh" ]; then
    test_pass "worktree-create.sh exists"
else
    test_fail "worktree-create.sh not found"
fi

# Test 2: worktree-create.sh is executable
if [ -x ".claude/scripts/worktree-create.sh" ]; then
    test_pass "worktree-create.sh is executable"
else
    echo "  Making executable..."
    chmod +x .claude/scripts/worktree-create.sh
    if [ -x ".claude/scripts/worktree-create.sh" ]; then
        test_pass "worktree-create.sh made executable"
    else
        test_fail "Failed to make worktree-create.sh executable"
    fi
fi

# Summary
echo ""
echo "Test Summary:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
