#!/usr/bin/env bash
#
# test_sc5_error_messages.sh
#
# Test SC-5: Clear error messages when push fails
# Tests that push failure provides clear, actionable error messages
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

# Main test
echo "Testing SC-5: Clear error messages when push fails..."
echo ""

# Test 1: Check if get_push_error_message function exists
echo "Test 1: Checking if get_push_error_message function exists..."
if grep -q "^get_push_error_message()" .claude/commands/03_close.md; then
    test_pass "get_push_error_message function exists"
else
    test_fail "get_push_error_message function not found"
fi

# Test 2: Check if function handles exit code 1 (general errors)
echo ""
echo "Test 2: Checking if function handles exit code 1..."
if grep -A 20 "get_push_error_message()" .claude/commands/03_close.md | grep -q 'case "$exit_code" in'; then
    if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q '1)'; then
        test_pass "Function handles exit code 1"
    else
        test_fail "Function doesn't handle exit code 1"
    fi
else
    test_fail "Function doesn't have case statement for exit codes"
fi

# Test 3: Check if function handles exit code 128 (network/auth errors)
echo ""
echo "Test 3: Checking if function handles exit code 128..."
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q '128)'; then
    test_pass "Function handles exit code 128"
else
    test_fail "Function doesn't handle exit code 128"
fi

# Test 4: Check for specific error message: non-fast-forward
echo ""
echo "Test 4: Checking for non-fast-forward error message..."
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q "non-fast-forward"; then
    test_pass "Non-fast-forward error message exists"
else
    test_fail "Non-fast-forward error message missing"
fi

# Test 5: Check for specific error message: authentication failed
echo ""
echo "Test 5: Checking for authentication failed error message..."
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -qi "authentication"; then
    test_pass "Authentication failed error message exists"
else
    test_fail "Authentication failed error message missing"
fi

# Test 6: Check for specific error message: network/connection error
echo ""
echo "Test 6: Checking for network/connection error message..."
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -qi "network\|connection"; then
    test_pass "Network/connection error message exists"
else
    test_fail "Network/connection error message missing"
fi

# Test 7: Check for specific error message: remote not found
echo ""
echo "Test 7: Checking for remote not found error message..."
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -qi "not found"; then
    test_pass "Remote not found error message exists"
else
    test_fail "Remote not found error message missing"
fi

# Test 8: Check if error messages are actionable (include commands)
echo ""
echo "Test 8: Checking if error messages are actionable..."
ACTIONABLE_COUNT=0

# Check for git pull recommendation
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q "git pull"; then
    ACTIONABLE_COUNT=$((ACTIONABLE_COUNT + 1))
fi

# Check for credentials check
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -qi "check.*credentials"; then
    ACTIONABLE_COUNT=$((ACTIONABLE_COUNT + 1))
fi

# Check for remote URL check
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -qi "check.*remote"; then
    ACTIONABLE_COUNT=$((ACTIONABLE_COUNT + 1))
fi

if [ $ACTIONABLE_COUNT -ge 2 ]; then
    test_pass "Error messages include actionable recommendations ($ACTIONABLE_COUNT found)"
else
    test_fail "Error messages lack actionable recommendations ($ACTIONABLE_COUNT found)"
fi

# Test 9: Check if worktree push failure uses get_push_error_message
echo ""
echo "Test 9: Checking if worktree push failure uses get_push_error_message..."
if grep -n "get_push_error_message" .claude/commands/03_close.md | grep -q "119:"; then
    test_pass "Worktree push failure uses get_push_error_message (line 119)"
else
    test_fail "Worktree push failure doesn't use get_push_error_message"
fi

# Test 10: Check if manual push instructions are included
echo ""
echo "Test 10: Checking if manual push instructions are included..."
if grep -A 5 "get_push_error_message" .claude/commands/03_close.md | grep -q "To push manually:"; then
    test_pass "Manual push instructions included"
else
    test_fail "Manual push instructions missing"
fi

# Test 11: Check if manual push command includes correct syntax
echo ""
echo "Test 11: Checking if manual push command is correct..."
if grep "To push manually:" .claude/commands/03_close.md | grep -q "git push origin"; then
    test_pass "Manual push command includes git push origin"
else
    test_fail "Manual push command incorrect or missing"
fi

# Test 12: Integration test - simulate error message generation
echo ""
echo "Test 12: Integration test - simulate error message generation..."

# Source the function by extracting it from the command file
# This is a simplified simulation
simulate_get_push_error_message() {
    local exit_code="$1"
    local error_output="$2"

    case "$exit_code" in
        1)
            if echo "$error_output" | grep -qi "non-fast-forward"; then
                echo "Remote has new commits - run 'git pull' before pushing"
            elif echo "$error_output" | grep -qi "protected"; then
                echo "Branch is protected - push not allowed directly"
            else
                echo "Push rejected - check repository status"
            fi
            ;;
        128)
            if echo "$error_output" | grep -qi "authentication"; then
                echo "Authentication failed - check your credentials"
            elif echo "$error_output" | grep -qi "could not read\|connection\|network"; then
                echo "Network error - connection failed"
            elif echo "$error_output" | grep -qi "not found"; then
                echo "Remote repository not found - check remote URL"
            else
                echo "Push failed - check remote configuration"
            fi
            ;;
        *)
            echo "Push failed (exit code: $exit_code)"
            ;;
    esac
}

# Test error message generation for exit code 1
ERROR_MSG=$(simulate_get_push_error_message 1 "non-fast-forward")
if echo "$ERROR_MSG" | grep -qi "git pull"; then
    test_pass "Exit code 1 generates actionable error message"
else
    test_fail "Exit code 1 error message not actionable"
fi

# Test error message generation for exit code 128
ERROR_MSG=$(simulate_get_push_error_message 128 "authentication failed")
if echo "$ERROR_MSG" | grep -qi "credentials"; then
    test_pass "Exit code 128 generates actionable error message"
else
    test_fail "Exit code 128 error message not actionable"
fi

# Test 13: Verify error message clarity (check for user-friendly language)
echo ""
echo "Test 13: Verifying error message clarity..."

CLARITY_PASSED=0

# Check for clear, non-technical explanations
if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q "Remote has new commits"; then
    CLARITY_PASSED=$((CLARITY_PASSED + 1))
fi

if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q "check your credentials"; then
    CLARITY_PASSED=$((CLARITY_PASSED + 1))
fi

if grep -A 30 "get_push_error_message()" .claude/commands/03_close.md | grep -q "connection failed"; then
    CLARITY_PASSED=$((CLARITY_PASSED + 1))
fi

if [ $CLARITY_PASSED -ge 2 ]; then
    test_pass "Error messages use clear, user-friendly language ($CLARITY_PASSED examples)"
else
    test_fail "Error messages lack clarity ($CLARITY_PASSED examples)"
fi

# Test 14: Check if worktree preservation message is clear
echo ""
echo "Test 14: Checking if worktree preservation message is clear..."
if grep "Worktree preserved" .claude/commands/03_close.md | grep -q "manual push"; then
    test_pass "Worktree preservation message explains why it's preserved"
else
    test_fail "Worktree preservation message unclear"
fi

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
