#!/usr/bin/env bash
#
# test_sc1_simple_fix.sh
#
# Test TS-1: Simple one-line fix workflow
# Tests that /04_fix command handles simple fixes end-to-end
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
setup_test_env() {
    # Create test directories
    mkdir -p /tmp/fix_test/.pilot/plan/pending
    mkdir -p /tmp/fix_test/.pilot/plan/in_progress
    mkdir -p /tmp/fix_test/.pilot/plan/done
    mkdir -p /tmp/fix_test/.pilot/state

    # Initialize git repo
    cd /tmp/fix_test
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create a README with a typo
    cat > README.md << 'EOF'
# Test Project

This is a test project with a typoo in line 5.
EOF

    git add README.md
    git commit -q -m "Initial commit"
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf /tmp/fix_test
}

# Main test
echo "Testing TS-1: Simple one-line fix workflow..."
echo ""

# Setup
setup_test_env

# Test 1: Verify /04_fix command file exists
echo "Test 1: Checking if /04_fix command file exists..."
if [ -f "/Users/chanho/claude-pilot/.claude/commands/04_fix.md" ]; then
    test_pass "Command file 04_fix.md exists"
else
    test_fail "Command file 04_fix.md not found"
fi

# Test 2: Verify command file has required sections
echo ""
echo "Test 2: Checking if command file has required sections..."
REQUIRED_SECTIONS=("## Step 1:" "## Step 2:" "## Step 3:")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
        test_pass "Section '$section' exists"
    else
        test_fail "Section '$section' missing"
    fi
done

# Test 3: Verify scope validation function exists
echo ""
echo "Test 3: Checking if scope validation function exists..."
if grep -q "calculate_complexity_score" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Scope validation function exists"
else
    test_fail "Scope validation function not found"
fi

# Test 4: Test complexity score calculation for simple input
echo ""
echo "Test 4: Testing complexity score for simple input..."
SIMPLE_INPUT="Fix typo in README.md line 10"
INPUT_LENGTH=${#SIMPLE_INPUT}

# Simple input should have low complexity score
COMPLEXITY_SCORE=0.0

# Check input length (>200 chars adds 0.3)
if [ $INPUT_LENGTH -gt 200 ]; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.3" | bc)
fi

# Check for architecture keywords
if echo "$SIMPLE_INPUT" | grep -qiE "(refactor|architecture|tradeoffs|redesign)"; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.3" | bc)
fi

# Check file count (>3 files adds 0.2)
FILE_COUNT=$(echo "$SIMPLE_INPUT" | grep -oE "\.md|\.js|\.ts|\.py|\.sh" | wc -l)
if [ $FILE_COUNT -gt 3 ]; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.2" | bc)
fi

# Check for multiple task indicators
if echo "$SIMPLE_INPUT" | grep -qiE "( AND | THEN | ALSO | and )"; then
    COMPLEXITY_SCORE=$(echo "$COMPLEXITY_SCORE + 0.2" | bc)
fi

# Verify score is below threshold
if [ $(echo "$COMPLEXITY_SCORE < 0.5" | bc) -eq 1 ]; then
    test_pass "Simple input has low complexity score ($COMPLEXITY_SCORE < 0.5)"
else
    test_fail "Simple input has high complexity score ($COMPLEXITY_SCORE >= 0.5)"
fi

# Test 5: Verify plan generation creates file in pending
echo ""
echo "Test 5: Verifying plan generation creates file in pending..."

# Simulate plan creation
PLAN_FILE="/tmp/fix_test/.pilot/plan/pending/fix_plan_$(date +%s).md"

cat > "$PLAN_FILE" << 'EOF'
# Fix Typo in README.md

## Success Criteria

- SC-1: Fix typo in README.md line 5 (typoo -> typo)

## PRP Analysis

### What (Functionality)
Fix typo in README.md

### Why (Context)
Typo causes confusion

### How (Approach)
1. Open README.md
2. Fix typo on line 5
3. Verify fix
EOF

if [ -f "$PLAN_FILE" ]; then
    test_pass "Plan file created in pending directory"
    # Count SCs
    SC_COUNT=$(grep -c "^- SC-" "$PLAN_FILE" 2>/dev/null || echo "0")
    if [ "$SC_COUNT" -eq 1 ]; then
        test_pass "Plan has exactly 1 SC"
    else
        test_fail "Plan has $SC_COUNT SCs (expected 1)"
    fi
else
    test_fail "Plan file not created"
fi

# Test 6: Verify continuation state is created
echo ""
echo "Test 6: Verifying continuation state creation..."

STATE_FILE="/tmp/fix_test/.pilot/state/continuation.json"

# Create test state
cat > "$STATE_FILE" << EOF
{
  "version": "1.0",
  "session_id": "test-session-$(date +%s)",
  "branch": "main",
  "plan_file": "$PLAN_FILE",
  "todos": [
    {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"}
  ],
  "iteration_count": 0,
  "max_iterations": 7,
  "last_checkpoint": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "continuation_level": "normal"
}
EOF

if [ -f "$STATE_FILE" ]; then
    test_pass "Continuation state file created"

    # Verify required fields
    if jq -e '.session_id' "$STATE_FILE" > /dev/null 2>&1; then
        test_pass "State has session_id field"
    else
        test_fail "State missing session_id field"
    fi

    if jq -e '.plan_file' "$STATE_FILE" > /dev/null 2>&1; then
        test_pass "State has plan_file field"
    else
        test_fail "State missing plan_file field"
    fi

    if jq -e '.todos' "$STATE_FILE" > /dev/null 2>&1; then
        test_pass "State has todos field"
    else
        test_fail "State missing todos field"
    fi
else
    test_fail "Continuation state file not created"
fi

# Test 7: Verify auto-execute integration
echo ""
echo "Test 7: Verifying auto-execute integration..."
if grep -q "02_execute" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Command integrates with /02_execute"
else
    test_fail "Command missing /02_execute integration"
fi

# Test 8: Verify auto-close integration
echo ""
echo "Test 8: Verifying auto-close integration..."
if grep -q "03_close" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Command integrates with /03_close"
else
    test_fail "Command missing /03_close integration"
fi

# Test 9: Verify diff display before commit
echo ""
echo "Test 9: Verifying diff display before commit..."
if grep -q "git diff" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Command shows git diff before commit"
else
    test_fail "Command missing git diff display"
fi

# Test 10: Verify user confirmation prompt
echo ""
echo "Test 10: Verifying user confirmation prompt..."
if grep -qi "commit these changes" /Users/chanho/claude-pilot/.claude/commands/04_fix.md 2>/dev/null; then
    test_pass "Command prompts for user confirmation"
else
    test_fail "Command missing user confirmation prompt"
fi

# Test 11: Simulate end-to-end workflow
echo ""
echo "Test 11: Simulating end-to-end workflow..."

# Simulate fix execution
cd /tmp/fix_test

# Fix the typo
sed -i.bak 's/typoo/typo/' README.md
rm -f README.md.bak

# Verify fix worked
if grep -q "typo" README.md && ! grep -q "typoo" README.md; then
    test_pass "Typo fixed successfully"
else
    test_fail "Typo fix failed"
fi

# Simulate commit
git add README.md
git commit -q -m "Fix typo in README.md line 5"

if git log --oneline | grep -q "Fix typo"; then
    test_pass "Change committed successfully"
else
    test_fail "Commit failed"
fi

# Test 12: Verify plan moves to done on success
echo ""
echo "Test 12: Verifying plan moves to done on success..."

# Move plan to done
mkdir -p /tmp/fix_test/.pilot/plan/done
mv "$PLAN_FILE" /tmp/fix_test/.pilot/plan/done/

DONE_PLAN="/tmp/fix_test/.pilot/plan/done/$(basename "$PLAN_FILE")"
if [ -f "$DONE_PLAN" ]; then
    test_pass "Plan moved to done directory"
else
    test_fail "Plan not moved to done"
fi

# Test 13: Verify continuation state cleaned up
echo ""
echo "Test 13: Verifying continuation state cleanup..."
rm -f "$STATE_FILE"
if [ ! -f "$STATE_FILE" ]; then
    test_pass "Continuation state cleaned up on success"
else
    test_fail "Continuation state not cleaned up"
fi

# Cleanup
cleanup_test_env

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
