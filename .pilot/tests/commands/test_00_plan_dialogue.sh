#!/bin/bash
# Test: /00_plan dialogue-based improvements (Superpowers patterns)
# Tests SC-1 through SC-5

set -e

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Assertions
assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_ge() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Value should be >= expected}"

    if [[ "$actual" -ge "$expected" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Expected >=: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Looking for: $needle"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

# Setup
PLAN_FILE="/Users/chanho/claude-pilot/.claude/commands/00_plan.md"
PROJECT_ROOT="/Users/chanho/claude-pilot"

echo "=== Testing /00_plan Dialogue Improvements ==="
echo ""

# Verify plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${RED}✗${NC} Plan file not found: $PLAN_FILE"
    exit 1
fi

# Read file content
PLAN_CONTENT=$(cat "$PLAN_FILE")

# SC-1: Dialogue-based question patterns (한 번에 하나씩 질문, 객관식 선호)
echo "=== SC-1: Dialogue-Based Question Patterns ==="
# Check for any of the patterns
SC_1_1_PASS=0
if echo "$PLAN_CONTENT" | grep -q "한 번에 하나씩" || echo "$PLAN_CONTENT" | grep -q "one at a time" || echo "$PLAN_CONTENT" | grep -q "Only one question per message"; then
    SC_1_1_PASS=1
    echo -e "${GREEN}✓${NC} SC-1.1: Should mention 'one question at a time' pattern"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-1.1: Should mention 'one question at a time' pattern"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

SC_1_2_PASS=0
if echo "$PLAN_CONTENT" | grep -q "객관식" || echo "$PLAN_CONTENT" | grep -qi "multiple choice"; then
    SC_1_2_PASS=1
    echo -e "${GREEN}✓${NC} SC-1.2: Should mention 'multiple choice' preference"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-1.2: Should mention 'multiple choice' preference"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))
echo ""

# SC-2: Alternative exploration (2-3 approaches + trade-off)
echo "=== SC-2: Alternative Exploration ==="
SC_2_1_PASS=0
if echo "$PLAN_CONTENT" | grep -q "접근법 탐색" || echo "$PLAN_CONTENT" | grep -q "Explore Approaches" || echo "$PLAN_CONTENT" | grep -q "Explore alternative approaches"; then
    SC_2_1_PASS=1
    echo -e "${GREEN}✓${NC} SC-2.1: Should have alternative exploration section"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-2.1: Should have alternative exploration section"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

SC_2_2_PASS=0
if echo "$PLAN_CONTENT" | grep -qi "trade-off" || echo "$PLAN_CONTENT" | grep -q "장점.*단점"; then
    SC_2_2_PASS=1
    echo -e "${GREEN}✓${NC} SC-2.2: Should mention trade-offs"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-2.2: Should mention trade-offs"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

SC_2_3_PASS=0
if echo "$PLAN_CONTENT" | grep -q "2-3.*접근법" || echo "$PLAN_CONTENT" | grep -q "2-3.*approach"; then
    SC_2_3_PASS=1
    echo -e "${GREEN}✓${NC} SC-2.3: Should mention 2-3 approaches"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-2.3: Should mention 2-3 approaches"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))
echo ""

# SC-3: Section-by-section design validation (200-300 words)
echo "=== SC-3: Section-by-Section Design Validation ==="
SC_3_1_PASS=0
if echo "$PLAN_CONTENT" | grep -q "섹션별" || echo "$PLAN_CONTENT" | grep -qi "Incremental"; then
    SC_3_1_PASS=1
    echo -e "${GREEN}✓${NC} SC-3.1: Should mention section-by-section validation"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-3.1: Should mention section-by-section validation"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

SC_3_2_PASS=0
if echo "$PLAN_CONTENT" | grep -q "200-300"; then
    SC_3_2_PASS=1
    echo -e "${GREEN}✓${NC} SC-3.2: Should mention 200-300 word sections"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} SC-3.2: Should mention 200-300 word sections"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))
echo ""

# SC-4: Backward compatibility with SPEC-First framework
echo "=== SC-4: Backward Compatibility ==="
assert_contains "$PLAN_CONTENT" "PRP Framework" \
    "SC-4.1: Should maintain PRP Framework"
assert_contains "$PLAN_CONTENT" "Requirements Coverage" \
    "SC-4.2: Should maintain Requirements Coverage Check"
echo ""

# SC-5: AskUserQuestion usage examples (3+ instances)
echo "=== SC-5: AskUserQuestion Usage Examples ==="
ASK_USER_COUNT=$(echo "$PLAN_CONTENT" | grep -c "AskUserQuestion" || true)
echo "AskUserQuestion occurrences: $ASK_USER_COUNT"
assert_ge 3 "$ASK_USER_COUNT" \
    "SC-5: Should have 3+ AskUserQuestion examples"
echo ""

# Additional verification: Step structure
echo "=== Additional Verification: Step Structure ==="
STEP_2_5_PASS=0
if echo "$PLAN_CONTENT" | grep -q "Step 2.5" || echo "$PLAN_CONTENT" | grep -q "Step 3.5" || echo "$PLAN_CONTENT" | grep -q "Step 4.5"; then
    STEP_2_5_PASS=1
    echo -e "${GREEN}✓${NC} Should have intermediate steps (2.5, 3.5, 4.5)"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Should have intermediate steps (2.5, 3.5, 4.5)"
    ((TESTS_FAILED++))
fi
((TESTS_RUN++))

assert_contains "$PLAN_CONTENT" "Step 1:" \
    "Should maintain Step 1 (Explore)"
assert_contains "$PLAN_CONTENT" "Step 2:" \
    "Should maintain Step 2 (Gather Requirements)"
assert_contains "$PLAN_CONTENT" "Step 3:" \
    "Should maintain Step 3 (Create SPEC-First Plan)"
assert_contains "$PLAN_CONTENT" "Step 5:" \
    "Should maintain Step 5 (Confirm Plan)"
echo ""

# Summary
echo "=== Test Results ==="
echo "  Run: $TESTS_RUN"
echo -e "  ${GREEN}Passed${NC}: $TESTS_PASSED"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "  ${RED}Failed${NC}: $TESTS_FAILED"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
