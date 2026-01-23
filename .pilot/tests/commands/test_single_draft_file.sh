#!/bin/bash
# Test: Single Draft File Strategy for /00_plan and /01_confirm
# Tests SC-1, SC-2, SC-3

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
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++)) || true
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Looking for: $needle"
        ((TESTS_FAILED++)) || true
    fi
    ((TESTS_RUN++)) || true
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should NOT contain substring}"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${RED}✗${NC} $message"
        echo "  Should NOT contain: $needle"
        ((TESTS_FAILED++)) || true
    else
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++)) || true
    fi
    ((TESTS_RUN++)) || true
}

# Setup
PLAN_FILE="/Users/chanho/claude-pilot/.claude/commands/00_plan.md"
CONFIRM_FILE="/Users/chanho/claude-pilot/.claude/commands/01_confirm.md"

echo "=== Testing Single Draft File Strategy ==="
echo ""

# Verify files exist
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${RED}✗${NC} Plan file not found: $PLAN_FILE"
    exit 1
fi

if [ ! -f "$CONFIRM_FILE" ]; then
    echo -e "${RED}✗${NC} Confirm file not found: $CONFIRM_FILE"
    exit 1
fi

# Read file content
PLAN_CONTENT=$(cat "$PLAN_FILE")
CONFIRM_CONTENT=$(cat "$CONFIRM_FILE")

# SC-1: /00_plan and /01_confirm use only one draft file per session
echo "=== SC-1: Single Draft File Naming ==="
echo ""
echo "Testing /00_plan.md..."
assert_contains "$PLAN_CONTENT" "*_draft.md" \
    "SC-1.1: /00_plan should use *_draft.md naming"
assert_not_contains "$PLAN_CONTENT" "*_decisions.md" \
    "SC-1.2: /00_plan should NOT reference *_decisions.md (old naming)"

echo ""
echo "Testing /01_confirm.md..."
assert_contains "$CONFIRM_CONTENT" "*_draft.md" \
    "SC-1.3: /01_confirm should use *_draft.md naming"
echo ""

# SC-2: /01_confirm reuses existing draft from /00_plan when available
echo "=== SC-2: Draft File Reuse ==="
assert_contains "$CONFIRM_CONTENT" "Load Draft" \
    "SC-2.1: /01_confirm should have step to load existing draft"
assert_contains "$CONFIRM_CONTENT" "reuse" \
    "SC-2.2: /01_confirm should mention reusing existing draft"
assert_contains "$CONFIRM_CONTENT" "update existing" \
    "SC-2.3: /01_confirm should update existing file when found"
assert_contains "$CONFIRM_CONTENT" "If not found" \
    "SC-2.4: /01_confirm should handle missing draft gracefully"
echo ""

# SC-3: After /01_confirm completes, the draft/ directory is empty
echo "=== SC-3: Draft Directory Cleanup ==="
assert_contains "$CONFIRM_CONTENT" "Move to pending" \
    "SC-3.1: /01_confirm should move file to pending/ directory"
assert_contains "$CONFIRM_CONTENT" "mv" \
    "SC-3.2: /01_confirm should use mv command to move files"
assert_contains "$CONFIRM_CONTENT" "pending/" \
    "SC-3.3: /01_confirm should mention pending/ directory"
echo ""

# Additional: Backward compatibility
echo "=== Additional: Backward Compatibility ==="
assert_contains "$CONFIRM_CONTENT" "*_decisions.md" \
    "Backward Compat: /01_confirm should check for *_decisions.md for backward compatibility"
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
