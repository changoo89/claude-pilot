#!/bin/bash
# continue_command_test.sh: Test /00_continue command workflow
# TS-6: /00_continue resume workflow (verify agent resumes from last checkpoint)

set -euo pipefail

# Test environment setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/.pilot/scripts"
STATE_DIR="$PROJECT_ROOT/.pilot/state"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/00_continue.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_start() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "\n${YELLOW}Test $TESTS_RUN:${NC} $1"
}

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}  PASS${NC}: $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}  FAIL${NC}: $1"
    echo "    Expected: $2"
    echo "    Got: $3"
}

# Cleanup function
cleanup() {
    # Save real state if it exists
    if [ -f "$STATE_DIR/continuation.json" ]; then
        mv "$STATE_DIR/continuation.json" "$STATE_DIR/continuation.json.save" 2>/dev/null || true
    fi
}

# Setup cleanup trap
trap cleanup EXIT

echo "=========================================="
echo "/00_continue Command Tests (TS-6)"
echo "=========================================="

# Test 1: Command file exists
test_start "Command file exists at .claude/commands/00_continue.md"
if [ -f "$COMMAND_FILE" ]; then
    test_pass "Command file exists"
else
    test_fail "Command file to exist" "file at $COMMAND_FILE" "file not found"
fi

# Test 2: Command file contains continuation logic
test_start "Command file contains continuation state references"
if grep -q "continuation state" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command file contains continuation state logic"
else
    test_fail "Command file to contain continuation logic" "'continuation state' keyword" "keyword not found"
fi

# Test 3: State file check logic exists
test_start "Command includes state file existence check"
if grep -q "STATE_FILE" "$COMMAND_FILE" 2>/dev/null && \
   grep -q "\[ ! -f" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes state file check"
else
    test_fail "Command to include state file check" "file existence check" "check not found"
fi

# Test 4: Load state step exists
test_start "Command includes load state step"
if grep -q "Load State\|Load continuation" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes load state step"
else
    test_fail "Command to include load state step" "load state section" "section not found"
fi

# Test 5: State validation exists
test_start "Command includes state validation (branch, plan, iteration)"
if grep -q "Validate State\|Verify.*branch\|Verify.*plan" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes state validation"
else
    test_fail "Command to include state validation" "validation step" "step not found"
fi

# Test 6: Resume work step exists
test_start "Command includes resume work step"
if grep -q "Resume Work\|Find.*incomplete.*todo\|next.*todo" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes resume work step"
else
    test_fail "Command to include resume work step" "resume work section" "section not found"
fi

# Test 7: Error handling for missing state file
test_start "Command includes error handling for missing state"
if grep -q "No continuation state\|state not found\|suggest.*00_plan" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes error handling for missing state"
else
    test_fail "Command to include error handling" "error message" "not found"
fi

# Test 8: Branch mismatch warning exists
test_start "Command includes branch mismatch warning"
if grep -q "branch.*mismatch\|Warning.*branch" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes branch mismatch warning"
else
    test_fail "Command to include branch warning" "branch check" "not found"
fi

# Test 9: Iteration limit check exists
test_start "Command includes iteration limit check"
if grep -q "max.*iteration\|iteration.*limit\|Maximum.*reached" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes iteration limit check"
else
    test_fail "Command to include iteration limit" "limit check" "not found"
fi

# Test 10: Integration with state scripts
test_start "Command integrates with state management scripts"
if grep -q "state_read\.sh\|state_write\.sh" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command integrates with state scripts"
else
    test_fail "Command to integrate with state scripts" "script references" "not found"
fi

# Test 11: Integration with related commands
test_start "Command references related commands (/00_plan, /02_execute, /03_close)"
if grep -q "/00_plan\|/02_execute\|/03_close" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command references related commands"
else
    test_fail "Command to reference related commands" "command links" "not found"
fi

# Test 12: Escape hatch documentation exists
test_start "Command documents escape hatch commands (/cancel, /stop, /done)"
if grep -q "Escape Hatch\|/cancel\|/stop\|/done" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command documents escape hatch"
else
    test_fail "Command to document escape hatch" "escape hatch section" "not found"
fi

# Test 13: Example usage exists
test_start "Command includes example usage"
if grep -q "Example Usage\|example\|Usage:" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes example usage"
else
    test_fail "Command to include example usage" "example section" "not found"
fi

# Test 14: Continuation system guide reference exists
test_start "Command references continuation system guide"
if grep -q "continuation-system\|Continuation System Guide" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command references continuation guide"
else
    test_fail "Command to reference continuation guide" "guide link" "not found"
fi

# Test 15: Error handling table exists
test_start "Command includes error handling table"
if grep -q "Error Handling\|Error.*Cause.*Action" "$COMMAND_FILE" 2>/dev/null; then
    test_pass "Command includes error handling table"
else
    test_fail "Command to include error handling table" "error table" "not found"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "=========================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
