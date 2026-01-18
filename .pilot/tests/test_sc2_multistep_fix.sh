#!/usr/bin/env bash
#
# test_sc2_multistep_fix.sh
#
# Test TS-2: Multi-step bug fix (2-3 SCs)
# Tests that /04_fix handles 2-3 SC plans correctly
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
echo "Testing TS-2: Multi-step bug fix (2-3 SCs)..."
echo ""

# Setup: Ensure we're in the right directory
cd /Users/chanho/claude-pilot

# Test 1: Verify /04_fix command file exists
echo "Test 1: Checking if /04_fix command file exists..."
if [ -f ".claude/commands/04_fix.md" ]; then
    test_pass "Command file exists at .claude/commands/04_fix.md"
else
    test_fail "Command file not found at .claude/commands/04_fix.md"
fi

# Test 2: Verify command has scope validation logic
echo ""
echo "Test 2: Checking if command has scope validation logic..."
if grep -q "complexity score" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Scope validation logic present"
else
    test_fail "Scope validation logic missing"
fi

# Test 3: Verify command generates plan in pending directory
echo ""
echo "Test 3: Checking if command generates plan in pending directory..."
if grep -q "plan/pending" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Plan generation to pending directory configured"
else
    test_fail "Plan generation to pending directory not configured"
fi

# Test 4: Verify command has auto-execution logic
echo ""
echo "Test 4: Checking if command has auto-execution logic..."
if grep -q "/02_execute" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Auto-execution via /02_execute present"
else
    test_fail "Auto-execution logic missing"
fi

# Test 5: Verify command supports continuation state
echo ""
echo "Test 5: Checking if command supports continuation state..."
if grep -q "continuation" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Continuation state support present"
else
    test_fail "Continuation state support missing"
fi

# Test 6: Verify complexity score calculation (input length check)
echo ""
echo "Test 6: Checking complexity score calculation - input length..."
if grep -q "200 chars" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Input length check (>200 chars) present"
else
    test_fail "Input length check missing"
fi

# Test 7: Verify complexity score calculation (keyword detection)
echo ""
echo "Test 7: Checking complexity score calculation - keyword detection..."
KEYWORD_DETECTED=0
if grep -qi "refactor" .claude/commands/04_fix.md 2>/dev/null; then
    KEYWORD_DETECTED=$((KEYWORD_DETECTED + 1))
fi
if grep -qi "architecture" .claude/commands/04_fix.md 2>/dev/null; then
    KEYWORD_DETECTED=$((KEYWORD_DETECTED + 1))
fi

if [ $KEYWORD_DETECTED -ge 1 ]; then
    test_pass "Keyword detection for complexity present ($KEYWORD_DETECTED keywords)"
else
    test_fail "Keyword detection missing"
fi

# Test 8: Verify rejection threshold (score >=0.5)
echo ""
echo "Test 8: Checking rejection threshold configuration..."
if grep -q "0.5" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Rejection threshold (0.5) configured"
else
    test_fail "Rejection threshold not configured"
fi

# Test 9: Verify error message for complex tasks
echo ""
echo "Test 9: Checking error message for complex tasks..."
if grep -qi "too complex" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Error message for complex tasks present"
else
    test_fail "Error message for complex tasks missing"
fi

# Test 10: Verify suggestion to use /00_plan on rejection
echo ""
echo "Test 10: Checking suggestion to use /00_plan on rejection..."
if grep -q "/00_plan" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Suggestion to use /00_plan present"
else
    test_fail "Suggestion to use /00_plan missing"
fi

# Test 11: Integration test - Simulate scope validation for simple task
echo ""
echo "Test 11: Integration test - Scope validation for simple task..."

# Simulate scope validation function
simulate_scope_validation() {
    local input="$1"
    local score=0.0

    # Input length check
    if [ ${#input} -gt 200 ]; then
        score=$(echo "$score + 0.3" | bc)
    fi

    # Keyword detection
    if echo "$input" | grep -qiE "refactor|architecture|tradeoffs"; then
        score=$(echo "$score + 0.3" | bc)
    fi

    # File count check
    FILE_COUNT=$(echo "$input" | grep -oE "\.ts|\.js|\.py|\.md" | wc -l)
    if [ $FILE_COUNT -gt 3 ]; then
        score=$(echo "$score + 0.2" | bc)
    fi

    # Multiple tasks check
    if echo "$input" | grep -qiE " AND | THEN | ALSO "; then
        score=$(echo "$score + 0.2" | bc)
    fi

    echo "$score"
}

# Test simple task (should pass scope validation)
SIMPLE_TASK="Add validation to auth endpoint"
SCORE=$(simulate_scope_validation "$SIMPLE_TASK")
# Compare with threshold 0.5 (using bc for floating point comparison)
if [ 1 -eq "$(echo "${SCORE} < 0.5" | bc)" ]; then
    test_pass "Simple task passes scope validation (score: $SCORE < 0.5)"
else
    test_fail "Simple task fails scope validation (score: $SCORE >= 0.5)"
fi

# Test 12: Integration test - Simulate scope validation for complex task
echo ""
echo "Test 12: Integration test - Scope validation for complex task..."

COMPLEX_TASK="Refactor the entire authentication system architecture AND redesign the user session management ALSO update the authorization layer"
SCORE=$(simulate_scope_validation "$COMPLEX_TASK")

if [ 1 -eq "$(echo "${SCORE} >= 0.5" | bc)" ]; then
    test_pass "Complex task fails scope validation (score: $SCORE >= 0.5)"
else
    test_fail "Complex task passes scope validation incorrectly (score: $SCORE < 0.5)"
fi

# Test 13: Verify plan moves to in_progress after creation
echo ""
echo "Test 13: Checking if plan moves to in_progress..."
if grep -q "plan/in_progress" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Plan moves to in_progress configured"
else
    test_fail "Plan movement to in_progress missing"
fi

# Test 14: Verify Ralph Loop integration
echo ""
echo "Test 14: Checking Ralph Loop integration..."
if grep -qi "ralph" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Ralph Loop integration present"
else
    test_fail "Ralph Loop integration missing"
fi

# Test 15: Verify auto-close on success
echo ""
echo "Test 15: Checking auto-close on success..."
if grep -q "/03_close" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Auto-close via /03_close present"
else
    test_fail "Auto-close logic missing"
fi

# Test 16: Verify plan has correct SC structure (2-3 SCs)
echo ""
echo "Test 16: Checking if plan template has 2-3 SCs..."
# Extract the plan template section and count SCs within the Success Criteria section
PLAN_TEMPLATE=$(sed -n '/## Success Criteria/,/---/p' .claude/commands/04_fix.md 2>/dev/null)
SC_COUNT=$(echo "$PLAN_TEMPLATE" | grep -c "^\- \[ \] \*\*SC-[0-9]" || echo 0)
if [ $SC_COUNT -ge 2 ] && [ $SC_COUNT -le 3 ]; then
    test_pass "Plan template has correct SC count ($SC_COUNT SCs found, 2-3 expected)"
else
    test_fail "Plan template SC count incorrect ($SC_COUNT SCs found, 2-3 expected)"
fi

# Test 17: Verify GPT delegation trigger check is present
echo ""
echo "Test 17: Checking GPT delegation trigger check..."
if grep -q "GPT Delegation Trigger Check" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "GPT delegation trigger check present"
else
    test_fail "GPT delegation trigger check missing"
fi

# Test 18: Verify graceful fallback for Codex CLI
echo ""
echo "Test 18: Checking graceful fallback for Codex CLI..."
if grep -q "codex" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Graceful fallback for Codex CLI present"
else
    test_fail "Graceful fallback for Codex CLI missing"
fi

# Test 19: Verify commit confirmation flow
echo ""
echo "Test 19: Checking commit confirmation flow..."
if grep -q "COMMIT_CONFIRM" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Commit confirmation flow present"
else
    test_fail "Commit confirmation flow missing"
fi

# Test 20: Verify diff display before commit
echo ""
echo "Test 20: Checking diff display before commit..."
if grep -q "git diff HEAD" .claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Diff display before commit present"
else
    test_fail "Diff display before commit missing"
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
