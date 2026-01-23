#!/bin/bash
# Test: SC-5 - Superpowers-style refactor of /00_plan
# Verifies command is simplified and skill contains all logic

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
assert_lt() {
    local threshold="$1"
    local actual="$2"
    local message="${3:-Value should be < threshold}"

    if [[ "$actual" -lt "$threshold" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Threshold <: $threshold"
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

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should NOT contain substring}"

    if ! echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Should not contain: $needle"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist}"

    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  File: $file_path"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

# Setup
PROJECT_ROOT="/Users/chanho/claude-pilot"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/00_plan.md"
SKILL_FILE="$PROJECT_ROOT/.claude/skills/spec-driven-workflow/SKILL.md"

echo "=== Testing SC-5: Superpowers-Style 00_plan Refactor ==="
echo ""

# Test 1: Command file exists
echo "=== Test 1: Command File Exists ==="
assert_file_exists "$COMMAND_FILE" "00_plan.md should exist"
echo ""

# Test 2: Command file is simplified (< 20 lines)
echo "=== Test 2: Command Simplified (< 20 lines) ==="
COMMAND_LINES=$(wc -l < "$COMMAND_FILE")
echo "Command file lines: $COMMAND_LINES"
assert_lt 20 "$COMMAND_LINES" "00_plan.md should be < 20 lines"
echo ""

# Test 3: Command contains skill invocation
echo "=== Test 3: Command Contains Skill Invocation ==="
COMMAND_CONTENT=$(cat "$COMMAND_FILE")
assert_contains "$COMMAND_CONTENT" "Invoke the spec-driven-workflow skill" \
    "Command should invoke spec-driven-workflow skill"
assert_contains "$COMMAND_CONTENT" "Pass arguments: \$ARGUMENTS" \
    "Command should pass \$ARGUMENTS to skill"
echo ""

# Test 4: Command has no bash scripts (superpowers-style)
echo "=== Test 4: Command Has No Bash Scripts ==="
assert_not_contains "$COMMAND_CONTENT" '```bash' \
    "Command should NOT contain bash scripts"
assert_not_contains "$COMMAND_CONTENT" 'PROJECT_ROOT=' \
    "Command should NOT contain inline logic"
echo ""

# Test 5: Skill file exists
echo "=== Test 5: Skill File Exists ==="
assert_file_exists "$SKILL_FILE" "spec-driven-workflow/SKILL.md should exist"
echo ""

# Test 6: Skill contains all execution logic
echo "=== Test 6: Skill Contains Execution Logic ==="
if [ -f "$SKILL_FILE" ]; then
    SKILL_CONTENT=$(cat "$SKILL_FILE")

    # Check for key sections from original 00_plan.md
    assert_contains "$SKILL_CONTENT" "Step 1: Explore Codebase" \
        "Skill should contain Step 1 (Explore)"
    assert_contains "$SKILL_CONTENT" "Step 2: Gather Requirements" \
        "Skill should contain Step 2 (Requirements)"
    assert_contains "$SKILL_CONTENT" "Step 3: Create SPEC-First Plan" \
        "Skill should contain Step 3 (Plan)"
    assert_contains "$SKILL_CONTENT" "Step 4: Final User Decision" \
        "Skill should contain Step 4 (Decision)"

    # Check for execution patterns
    assert_contains "$SKILL_CONTENT" '```bash' \
        "Skill should contain bash scripts"
    assert_contains "$SKILL_CONTENT" 'PROJECT_ROOT=' \
        "Skill should contain execution logic"

    # Check for Question Filtering section
    assert_contains "$SKILL_CONTENT" "Question Filtering" \
        "Skill should contain Question Filtering section"

    # Check for Decision Tracking section
    assert_contains "$SKILL_CONTENT" "Decision Tracking" \
        "Skill should contain Decision Tracking section"

    # Check for EXECUTION DIRECTIVE
    assert_contains "$SKILL_CONTENT" "EXECUTION DIRECTIVE" \
        "Skill should contain EXECUTION DIRECTIVE"
else
    echo -e "${YELLOW}⚠${NC} Skill file not found - skipping logic tests"
    ((TESTS_RUN += 8))
    ((TESTS_FAILED += 8))
fi
echo ""

# Test 7: Frontmatter in command is correct
echo "=== Test 7: Command Frontmatter ==="
assert_contains "$COMMAND_CONTENT" "description:" \
    "Command should have description in frontmatter"
assert_contains "$COMMAND_CONTENT" "argument-hint:" \
    "Command should have argument-hint in frontmatter"
assert_contains "$COMMAND_CONTENT" "allowed-tools:" \
    "Command should have allowed-tools in frontmatter"
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
