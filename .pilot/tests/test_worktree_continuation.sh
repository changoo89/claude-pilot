#!/usr/bin/env bash
#
# test_worktree_continuation.sh
#
# Test continuation state in worktree context
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
echo "Testing worktree continuation state..."

# Test 1: Check jq is available
if command -v jq &> /dev/null; then
    test_pass "jq is available"
else
    test_fail "jq not found - required for state management"
fi

# Test 2: Check state directory structure
if [ -d ".pilot/state" ] || [ -d ".pilot/state" ]; then
    test_pass "State directory exists"
else
    test_fail "State directory not found"
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
