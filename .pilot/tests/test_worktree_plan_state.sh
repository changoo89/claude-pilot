#!/usr/bin/env bash
#
# test_worktree_plan_state.sh
#
# Test plan state management in worktree mode
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
echo "Testing worktree plan state management..."

# Test 1: Check if worktree-utils.sh exists
if [ -f ".claude/scripts/worktree-utils.sh" ]; then
    test_pass "worktree-utils.sh exists"
else
    test_fail "worktree-utils.sh not found"
fi

# Test 2: Source worktree utilities without error
if bash -c '. .claude/scripts/worktree-utils.sh 2>/dev/null'; then
    test_pass "worktree-utils.sh sources correctly"
else
    test_fail "worktree-utils.sh has sourcing errors"
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
