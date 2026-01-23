#!/usr/bin/env bash
# Test suite for docs-verify.sh
# Tests all success criteria: SC-1 through SC-5, SC-12, SC-13

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run test
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_exit="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "\n${YELLOW}Test $TESTS_RUN: $test_name${NC}"

    set +e
    eval "$test_cmd"
    local actual_exit=$?
    set -e

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL (expected exit $expected_exit, got $actual_exit)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Helper to check output contains string
check_output() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_string="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "\n${YELLOW}Test $TESTS_RUN: $test_name${NC}"

    set +e
    local output=$(eval "$test_cmd" 2>&1)
    set -e

    if echo "$output" | grep -q "$expected_string"; then
        echo -e "${GREEN}✓ PASS (found '$expected_string')${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL (expected to find '$expected_string')${NC}"
        echo "Output: $output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "================================================"
echo "docs-verify.sh Test Suite"
echo "================================================"

# SC-1: Script exists and runs without error
run_test "SC-1: Script exists and is executable" \
    "test -x /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    0

run_test "SC-1: Script runs successfully on clean repo" \
    "bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    0

# SC-2: Skill count validation
check_output "SC-2: Script validates skill count" \
    "bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    "Skill count"

# SC-3: Cross-reference validation
check_output "SC-3: Script validates cross-references" \
    "bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    "Cross-reference"

# SC-4: Line count validation
check_output "SC-4: Script validates line counts" \
    "bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    "Line count"

# SC-5: Pre-commit integration
run_test "SC-5: Pre-commit hook includes docs-verify" \
    "grep -q 'docs-verify' /Users/chanho/claude-pilot/.claude/scripts/hooks/pre-commit.sh" \
    0

# SC-12: Version sync validation
check_output "SC-12: Script validates version sync" \
    "bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh" \
    "Version sync"

# SC-13: Performance (<2 seconds)
TESTS_RUN=$((TESTS_RUN + 1))
echo -e "\n${YELLOW}Test $TESTS_RUN: SC-13: Script completes in under 2 seconds${NC}"
START_TIME=$(date +%s)
bash /Users/chanho/claude-pilot/.claude/scripts/docs-verify.sh > /dev/null 2>&1
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ "$DURATION" -lt 2 ]; then
    echo -e "${GREEN}✓ PASS (${DURATION}s < 2s)${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL (${DURATION}s >= 2s)${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Summary
echo ""
echo "================================================"
echo "Test Summary"
echo "================================================"
echo "Tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ "$TESTS_FAILED" -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo "Failed: 0"
fi
echo "================================================"

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
else
    exit 0
fi
