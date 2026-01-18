#!/usr/bin/env bash
#
# test_sc5_commit_confirmation.sh
#
# Test SC-4 (renumbered as TS-5): User confirmation before auto-commit
# Tests that /04_fix shows diff and asks for confirmation before committing
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
echo "Testing TS-5: User confirmation before auto-commit..."
echo ""

# Test 1: Check if /04_fix command file exists
echo "Test 1: Checking if /04_fix command file exists..."
if [ -f ".claude/commands/04_fix.md" ]; then
    test_pass "/04_fix command file exists"
else
    test_fail "/04_fix command file not found"
    echo "Note: This test requires /04_fix to be implemented"
    exit 1
fi

# Test 2: Check if Step 7 exists (User Confirmation Before Auto-Close)
echo ""
echo "Test 2: Checking if Step 7 (User Confirmation) exists..."
if grep -q "## Step 7: User Confirmation Before Auto-Close" .claude/commands/04_fix.md; then
    test_pass "Step 7 (User Confirmation) exists"
else
    test_fail "Step 7 (User Confirmation) not found"
fi

# Test 3: Check if git diff command is present
echo ""
echo "Test 3: Checking if git diff command is present..."
if grep -q "git diff HEAD" .claude/commands/04_fix.md; then
    test_pass "git diff HEAD command found"
else
    test_fail "git diff HEAD command not found"
fi

# Test 4: Check if diff display section exists
echo ""
echo "Test 4: Checking if diff display section exists..."
if grep -A 10 "## Step 7: User Confirmation" .claude/commands/04_fix.md | grep -q "Review Changes Before Commit"; then
    test_pass "Diff display section with header exists"
else
    test_fail "Diff display section header not found"
fi

# Test 5: Check if user prompt exists
echo ""
echo "Test 5: Checking if user prompt for confirmation exists..."
if grep -qi "Commit these changes" .claude/commands/04_fix.md; then
    test_pass "User confirmation prompt exists"
else
    test_fail "User confirmation prompt not found"
fi

# Test 6: Check if prompt includes y/n option
echo ""
echo "Test 6: Checking if prompt includes y/n option..."
if grep -qi "(y/n)" .claude/commands/04_fix.md; then
    test_pass "Prompt includes y/n option"
else
    test_fail "y/n option not found in prompt"
fi

# Test 7: Check if rejection handling exists
echo ""
echo "Test 7: Checking if rejection handling exists..."
if grep -A 20 "Commit these changes" .claude/commands/04_fix.md | grep -qi "No - keep changes"; then
    test_pass "Rejection handling option exists"
else
    test_fail "Rejection handling option not found"
fi

# Test 8: Check if /00_continue is suggested on rejection
echo ""
echo "Test 8: Checking if /00_continue is suggested on rejection..."
if grep -A 20 "Commit these changes" .claude/commands/04_fix.md | grep -q "/00_continue"; then
    test_pass "/00_continue suggestion exists on rejection"
else
    test_fail "/00_continue suggestion not found"
fi

# Test 9: Check if /03_close --no-commit is suggested on rejection
echo ""
echo "Test 9: Checking if /03_close --no-commit is suggested..."
if grep -A 20 "Commit these changes" .claude/commands/04_fix.md | grep -q "/03_close --no-commit"; then
    test_pass "/03_close --no-commit suggestion exists"
else
    test_fail "/03_close --no-commit suggestion not found"
fi

# Test 10: Check if COMMIT_CONFIRM variable is used
echo ""
echo "Test 10: Checking if COMMIT_CONFIRM variable is used..."
if grep -q "COMMIT_CONFIRM" .claude/commands/04_fix.md; then
    test_pass "COMMIT_CONFIRM variable exists"
else
    test_fail "COMMIT_CONFIRM variable not found"
fi

# Test 11: Check if default behavior requires confirmation
echo ""
echo "Test 11: Checking if default behavior requires confirmation..."
if grep -A 5 'COMMIT_CONFIRM=' .claude/commands/04_fix.md | grep -q 'COMMIT_CONFIRM.*false'; then
    test_pass "Default requires confirmation (COMMIT_CONFIRM=false)"
else
    test_fail "Default may not require confirmation"
fi

# Test 12: Check if Step 8 (Auto-Close on Success) only runs if confirmed
echo ""
echo "Test 12: Checking if Step 8 only runs if user confirms..."
if grep -A 30 "## Step 8: Auto-Close" .claude/commands/04_fix.md | grep -q 'COMMIT_CONFIRM.*true'; then
    test_pass "Step 8 checks for COMMIT_CONFIRM=true"
else
    test_fail "Step 8 doesn't check for confirmation"
fi

# Test 13: Check if confirmation section has clear header
echo ""
echo "Test 13: Checking if confirmation section has clear header..."
if grep -B 5 "git diff HEAD" .claude/commands/04_fix.md | grep -q "Review Changes Before Commit"; then
    test_pass "Confirmation section has clear header"
else
    test_fail "Confirmation section header unclear"
fi

# Test 14: Check if confirmation happens after completion check
echo ""
echo "Test 14: Checking if confirmation happens after completion..."
# Step 6 should be "Verify Completion", Step 7 should be "User Confirmation"
STEP6_LINE=$(grep -n "## Step 6: Verify Completion" .claude/commands/04_fix.md | cut -d: -f1)
STEP7_LINE=$(grep -n "## Step 7: User Confirmation" .claude/commands/04_fix.md | cut -d: -f1)

if [ -n "$STEP6_LINE" ] && [ -n "$STEP7_LINE" ] && [ "$STEP6_LINE" -lt "$STEP7_LINE" ]; then
    test_pass "Confirmation happens after completion check (Step 6 < Step 7)"
else
    test_fail "Confirmation order incorrect or steps not found"
fi

# Test 15: Integration test - verify confirmation flow logic
echo ""
echo "Test 15: Integration test - verify confirmation flow logic..."

# Extract confirmation logic and verify it has proper structure
CONFIRMATION_SECTION=$(sed -n '/## Step 7: User Confirmation/,/## Step 8:/p' .claude/commands/04_fix.md)

# Check for the three key elements: diff, prompt, handling
HAS_DIFF=0
HAS_PROMPT=0
HAS_HANDLING=0

if echo "$CONFIRMATION_SECTION" | grep -q "git diff HEAD"; then
    HAS_DIFF=1
fi

if echo "$CONFIRMATION_SECTION" | grep -qi "Commit these changes"; then
    HAS_PROMPT=1
fi

if echo "$CONFIRMATION_SECTION" | grep -q "/00_continue" && echo "$CONFIRMATION_SECTION" | grep -q "/03_close --no-commit"; then
    HAS_HANDLING=1
fi

if [ $HAS_DIFF -eq 1 ] && [ $HAS_PROMPT -eq 1 ] && [ $HAS_HANDLING -eq 1 ]; then
    test_pass "Confirmation flow has all required elements (diff, prompt, handling)"
else
    test_fail "Confirmation flow incomplete (diff: $HAS_DIFF, prompt: $HAS_PROMPT, handling: $HAS_HANDLING)"
fi

# Test 16: Check if commit message includes user confirmation note
echo ""
echo "Test 16: Checking if commit flow includes confirmation check..."
if grep -A 30 "## Step 8: Auto-Close" .claude/commands/04_fix.md | grep -q 'if \[ "$COMMIT_CONFIRM" = "true" \]'; then
    test_pass "Commit flow checks for user confirmation"
else
    test_fail "Commit flow doesn't check confirmation properly"
fi

# Test 17: Check if plan is NOT closed without confirmation
echo ""
echo "Test 17: Checking if plan remains open without confirmation..."
if grep -A 50 "## Step 8: Auto-Close" .claude/commands/04_fix.md | grep -qi "Plan not closed.*awaiting confirmation"; then
    test_pass "Plan remains open when not confirmed"
else
    test_fail "Plan closing logic may not respect confirmation"
fi

# Test 18: Verify error handling when COMMIT_CONFIRM is not set
echo ""
echo "Test 18: Verifying default COMMIT_CONFIRM behavior..."
if grep -A 10 'COMMIT_CONFIRM=' .claude/commands/04_fix.md | grep -q 'COMMIT_CONFIRM.*\${COMMIT_CONFIRM:-false}'; then
    test_pass "COMMIT_CONFIRM has safe default (false)"
else
    # Check if default is set in another way
    if grep 'COMMIT_CONFIRM.*false' .claude/commands/04_fix.md | grep -q 'COMMIT_CONFIRM.*='; then
        test_pass "COMMIT_CONFIRM default set to false"
    else
        test_skip "COMMIT_CONFIRM default behavior unclear (may use different pattern)"
    fi
fi

# Test 19: Check if diff output is shown before prompt
echo ""
echo "Test 19: Checking if diff is shown before prompt..."
# Extract lines between "git diff HEAD" and "Commit these changes"
DIFF_LINE=$(grep -n "git diff HEAD" .claude/commands/04_fix.md | head -1 | cut -d: -f1)
PROMPT_LINE=$(grep -n "Commit these changes" .claude/commands/04_fix.md | head -1 | cut -d: -f1)

if [ -n "$DIFF_LINE" ] && [ -n "$PROMPT_LINE" ] && [ "$DIFF_LINE" -lt "$PROMPT_LINE" ]; then
    test_pass "Diff is shown before prompt (diff line: $DIFF_LINE < prompt line: $PROMPT_LINE)"
else
    test_fail "Diff and prompt order incorrect or not found"
fi

# Test 20: Verify no automatic commit without explicit confirmation
echo ""
echo "Test 20: Verifying no automatic commit without explicit confirmation..."
# Check that git commit is inside a conditional block with COMMIT_CONFIRM
# Extract a larger section around git commit to find the guarding condition
if grep -B 30 "git commit" .claude/commands/04_fix.md | grep -q 'COMMIT_CONFIRM.*=.*true'; then
    test_pass "Commit is guarded by COMMIT_CONFIRM check"
else
    test_fail "Commit may happen without confirmation"
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
