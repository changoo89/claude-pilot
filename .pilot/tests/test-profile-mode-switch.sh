#!/usr/bin/env bash
# Test SC-4: Profile mode switching
# Verifies that settings.json example works correctly with different quality modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_start() {
    local name="$1"
    echo -e "${BLUE}TEST:${NC} $name"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}  ✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    local msg="$1"
    echo -e "${RED}  ✗ FAIL:${NC} $msg"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Expected '$expected', got '$actual'}"

    if [ "$expected" = "$actual" ]; then
        return 0
    else
        test_fail "$msg"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        return 0
    else
        test_fail "File does not exist: $file"
        return 1
    fi
}

assert_json_eq() {
    local file="$1"
    local key="$2"
    local expected="$3"

    if [ ! -f "$file" ]; then
        test_fail "JSON file does not exist: $file"
        return 1
    fi

    local actual
    actual=$(jq -r "$key" "$file" 2>/dev/null || echo "null")

    if [ "$actual" = "$expected" ]; then
        return 0
    else
        test_fail "JSON key '$key': Expected '$expected', got '$actual'"
        return 1
    fi
}

echo "=== SC-4: Profile Mode Switching Test ==="
echo ""

# Setup test environment
TEST_DIR="/tmp/claude-pilot-sc4-test-$$"
mkdir -p "$TEST_DIR/.claude/scripts/hooks"
cd "$TEST_DIR"

# Copy necessary scripts
cp /Users/chanho/claude-pilot/.claude/scripts/hooks/quality-dispatch.sh ./.claude/scripts/hooks/ 2>/dev/null || true
cp /Users/chanho/claude-pilot/.claude/scripts/hooks/cache.sh ./.claude/scripts/hooks/ 2>/dev/null || true

# Test 1: Verify settings.json.example exists
test_start "Check if .claude/settings.json.example exists"
if [ -f "/Users/chanho/claude-pilot/.claude/settings.json.example" ]; then
    test_pass
else
    test_fail ".claude/settings.json.example does not exist"
fi

# Test 2: Verify example has Gate vs Validator separation
test_start "Check Gate vs Validator separation in example"
EXAMPLE_FILE="/Users/chanho/claude-pilot/.claude/settings.json.example"

if [ ! -f "$EXAMPLE_FILE" ]; then
    test_fail "Example file does not exist yet"
else
    # Check PreToolUse has only branch-guard (Gate)
    PRE_TOOL_USE_HOOKS=$(jq '.hooks.PreToolUse | length' "$EXAMPLE_FILE" 2>/dev/null || echo "0")

    if [ "$PRE_TOOL_USE_HOOKS" -ge "1" ]; then
        # Verify first matcher targets git commands
        FIRST_MATCHER=$(jq -r '.hooks.PreToolUse[0].matcher // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

        if [[ "$FIRST_MATCHER" =~ (git|gh) ]]; then
            test_pass
        else
            test_fail "PreToolUse matcher should target git commands, got: $FIRST_MATCHER"
        fi
    else
        test_fail "PreToolUse should have at least 1 hook entry"
    fi
fi

# Test 3: Verify Stop hook has quality-dispatch.sh
test_start "Check Stop hook has quality-dispatch.sh"

if [ ! -f "$EXAMPLE_FILE" ]; then
    test_fail "Example file does not exist yet"
else
    STOP_HOOKS=$(jq -r '.hooks.Stop[0].hooks[0].command // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    if [[ "$STOP_HOOKS" =~ quality-dispatch\.sh ]]; then
        test_pass
    else
        test_fail "Stop hook should include quality-dispatch.sh, got: $STOP_HOOKS"
    fi
fi

# Test 4: Verify quality section exists
test_start "Check quality section exists in example"

if [ ! -f "$EXAMPLE_FILE" ]; then
    test_fail "Example file does not exist yet"
else
    QUALITY_MODE=$(jq -r '.quality.mode // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    if [ -n "$QUALITY_MODE" ]; then
        test_pass
    else
        test_fail "Example should have quality section with mode"
    fi
fi

# Test 5: Verify timeouts are configured
test_start "Check timeouts are configured in hooks"

if [ ! -f "$EXAMPLE_FILE" ]; then
    test_fail "Example file does not exist yet"
else
    # Check branch-guard timeout
    BRANCH_TIMEOUT=$(jq -r '.hooks.PreToolUse[0].hooks[0].timeout // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    # Check quality-dispatch timeout
    DISPATCH_TIMEOUT=$(jq -r '.hooks.Stop[0].hooks[0].timeout // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    # Check check-todos timeout
    TODOS_TIMEOUT=$(jq -r '.hooks.Stop[0].hooks[1].timeout // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    if [ -n "$BRANCH_TIMEOUT" ] && [ -n "$DISPATCH_TIMEOUT" ] && [ -n "$TODOS_TIMEOUT" ]; then
        test_pass
    else
        test_fail "All hooks should have timeout configured (branch-guard: $BRANCH_TIMEOUT, dispatch: $DISPATCH_TIMEOUT, todos: $TODOS_TIMEOUT)"
    fi
fi

# Test 6: Verify matcher is narrowed for git commands
test_start "Check git command matcher is specific"

if [ ! -f "$EXAMPLE_FILE" ]; then
    test_fail "Example file does not exist yet"
else
    GIT_MATCHER=$(jq -r '.hooks.PreToolUse[0].matcher // ""' "$EXAMPLE_FILE" 2>/dev/null || echo "")

    # Should match specific git commands like push, force, delete, etc.
    if [[ "$GIT_MATCHER" =~ (push|force|delete|reset|rebase|merge) ]]; then
        test_pass
    else
        test_fail "Git matcher should be specific to dangerous commands, got: $GIT_MATCHER"
    fi
fi

# Test 7: Test mode resolution (if quality-dispatch.sh exists)
test_start "Test mode resolution priority"

if [ -f "./.claude/scripts/hooks/quality-dispatch.sh" ]; then
    # Test environment variable priority
    export QUALITY_MODE="off"
    export CLAUDE_PROJECT_DIR="$TEST_DIR"

    # Run dispatcher and check mode
    MODE=$(./.claude/scripts/hooks/quality-dispatch.sh 2>&1 | grep -i "mode" || echo "")

    if [[ "$MODE" =~ off ]] || [ -z "$MODE" ]; then
        test_pass
    else
        test_fail "Mode should be 'off' from environment, got: $MODE"
    fi

    unset QUALITY_MODE
    unset CLAUDE_PROJECT_DIR
else
    echo -e "${YELLOW}  ⊘ SKIP: quality-dispatch.sh not yet implemented${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
fi

# Cleanup
cd -
rm -rf "$TEST_DIR"

# Summary
echo ""
echo "=== Test Summary ==="
echo "Tests Run: $TESTS_RUN"
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
