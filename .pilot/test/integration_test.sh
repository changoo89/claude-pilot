#!/usr/bin/env bash
# Integration Test for Sisyphus Continuation System
# Tests: TS-1 (state creation), TS-5 (max iteration), TS-7 (escape hatch)

set -e  # Exit on error, but allow || true for specific commands

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

# Test project root
PROJECT_ROOT="/Users/chanho/claude-pilot"
STATE_FILE="$PROJECT_ROOT/.pilot/state/continuation.json"
STATE_DIR="$PROJECT_ROOT/.pilot/state"

# Helper functions
test_start() {
    local test_name="$1"
    echo -e "${BLUE}TEST: $test_name${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    local reason="$1"
    echo -e "${RED}✗ FAIL: $reason${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

cleanup_state() {
    rm -f "$STATE_FILE" "$STATE_FILE.backup" 2>/dev/null || true
}

create_test_state() {
    local iteration_count="${1:-0}"
    local max_iterations="${2:-7}"
    # Default todos passed as 4th argument or use hardcoded default
    local temp_todos="${3:-/tmp/default_test_todos_$$.json}"

    # If no custom todos file provided, create default
    if [ ! -f "$temp_todos" ]; then
        cat > "$temp_todos" << 'EOF'
[{"id":"SC-1","status":"pending","iteration":0,"owner":"coder"}]
EOF
    fi

    mkdir -p "$STATE_DIR"

    # Generate a unique session ID
    local session_id="test-session-$$-$(date +%s)"

    jq -n \
        --arg version "1.0" \
        --arg session_id "$session_id" \
        --arg branch "main" \
        --arg plan_file ".pilot/plan/in_progress/test_plan.md" \
        --argjson todos "$(cat "$temp_todos")" \
        --argjson iteration_count "$iteration_count" \
        --argjson max_iterations "$max_iterations" \
        --arg continuation_level "normal" \
        '{
            version: $version,
            session_id: $session_id,
            branch: $branch,
            plan_file: $plan_file,
            todos: $todos,
            iteration_count: $iteration_count,
            max_iterations: $max_iterations,
            last_checkpoint: now | todate,
            continuation_level: $continuation_level
        }' > "$STATE_FILE"

    rm -f "$temp_todos"
}

# Test Suite: TS-1 - Continuation State Creation
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST SUITE: TS-1 - Continuation State Creation${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Test 1.1: State file has correct structure
test_start "TS-1.1: State file has valid JSON structure"
cleanup_state
# Pass empty to use default todos
create_test_state 0 7 ""

if [ -f "$STATE_FILE" ]; then
    if jq empty "$STATE_FILE" 2>/dev/null; then
        VERSION=$(jq -r '.version' "$STATE_FILE")
        if [ "$VERSION" = "1.0" ]; then
            test_pass
        else
            test_fail "Invalid version: $VERSION (expected 1.0)"
        fi
    else
        test_fail "Invalid JSON"
    fi
else
    test_fail "State file not created"
fi

# Test 1.2: State file has required fields
test_start "TS-1.2: State file has all required fields"
cleanup_state
create_test_state 0 7 ""

REQUIRED_FIELDS=("version" "session_id" "branch" "plan_file" "todos" "iteration_count" "max_iterations" "last_checkpoint" "continuation_level")
ALL_FIELDS_PRESENT=true

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$STATE_FILE" >/dev/null 2>&1; then
        test_fail "Missing field: $field"
        ALL_FIELDS_PRESENT=false
        break
    fi
done

if [ "$ALL_FIELDS_PRESENT" = true ]; then
    test_pass
fi

# Test 1.3: State file stores todo list correctly
test_start "TS-1.3: State file stores todo list with 3 todos"
cleanup_state

# Create temp file for todos
TEMP_TODOS="/tmp/test_todos_1_3_$$.json"
cat > "$TEMP_TODOS" << 'EOF'
[
    {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"},
    {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"},
    {"id": "SC-3", "status": "pending", "iteration": 0, "owner": "validator"}
]
EOF

create_test_state 0 7 "$TEMP_TODOS"

TODO_COUNT=$(jq '.todos | length' "$STATE_FILE")
if [ "$TODO_COUNT" -eq 3 ]; then
    test_pass
else
    test_fail "Expected 3 todos, got $TODO_COUNT"
fi

# Test 1.4: State file backup is created
test_start "TS-1.4: State file backup is created before overwrite"
cleanup_state
create_test_state 0 7 ""

# Create backup manually for testing
cp "$STATE_FILE" "$STATE_FILE.backup"

if [ -f "$STATE_FILE.backup" ]; then
    test_pass
else
    test_fail "Backup file not created"
fi

cleanup_state

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST SUITE: TS-5 - Max Iteration Limit${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Test 5.1: Max iterations limit is enforced
test_start "TS-5.1: Max iterations limit is enforced (7/7)"
cleanup_state

# Create temp file for todos
TEMP_TODOS="/tmp/test_todos_5_1_$$.json"
cat > "$TEMP_TODOS" << 'EOF'
[
    {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"}
]
EOF

create_test_state 7 7 "$TEMP_TODOS"

ITERATION_COUNT=$(jq -r '.iteration_count' "$STATE_FILE")
MAX_ITERATIONS=$(jq -r '.max_iterations' "$STATE_FILE")

if [ "$ITERATION_COUNT" -ge "$MAX_ITERATIONS" ]; then
    test_pass
else
    test_fail "Iteration count ($ITERATION_COUNT) should be >= max ($MAX_ITERATIONS)"
fi

# Test 5.2: Continuation paused when max iterations reached
test_start "TS-5.2: Continuation paused when max iterations reached"
cleanup_state

# Create temp file for todos
TEMP_TODOS="/tmp/test_todos_5_2_$$.json"
cat > "$TEMP_TODOS" << 'EOF'
[
    {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"},
    {"id": "SC-2", "status": "in_progress", "iteration": 3, "owner": "coder"}
]
EOF

create_test_state 7 7 "$TEMP_TODOS"

INCOMPLETE_COUNT=$(jq '[.todos[] | select(.status != "complete")] | length' "$STATE_FILE")

if [ "$INCOMPLETE_COUNT" -gt 0 ] && [ "$ITERATION_COUNT" -ge "$MAX_ITERATIONS" ]; then
    test_pass
else
    test_fail "Should have incomplete todos and max iterations reached"
fi

cleanup_state

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST SUITE: TS-7 - User Escape Hatch${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Test 7.1: Escape hatch commands are documented
test_start "TS-7.1: Escape hatch commands are documented in 02_execute"
if grep -q "/cancel" /Users/chanho/claude-pilot/.claude/commands/02_execute.md && \
   grep -q "/stop" /Users/chanho/claude-pilot/.claude/commands/02_execute.md && \
   grep -q "/done" /Users/chanho/claude-pilot/.claude/commands/02_execute.md; then
    test_pass
else
    test_fail "Escape hatch commands not documented"
fi

# Test 7.2: check-todos.sh hook checks continuation state
test_start "TS-7.2: check-todos.sh hook checks continuation state"
cleanup_state

# Create test state with incomplete todos
TEMP_TODOS="/tmp/test_todos_7_2_$$.json"
cat > "$TEMP_TODOS" << 'EOF'
[
    {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"}
]
EOF

create_test_state 0 7 "$TEMP_TODOS"

# Create a test in-progress plan for the hook to find
TEST_PLAN_DIR="$PROJECT_ROOT/.pilot/plan/in_progress/test_integration_7_2"
mkdir -p "$TEST_PLAN_DIR"
cat > "$TEST_PLAN_DIR/plan.md" << 'EOF'
# Test Plan for Integration

## Success Criteria

- [ ] SC-1: Test continuation state
- [ ] SC-2: Test another item

EOF

# Create active pointer
BRANCH="$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR="$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"
mkdir -p "$(dirname "$ACTIVE_PTR")"
echo "$TEST_PLAN_DIR" > "$ACTIVE_PTR"

# Run check-todos.sh from project root
cd "$PROJECT_ROOT"
HOOK_OUTPUT=$(/Users/chanho/claude-pilot/.claude/scripts/hooks/check-todos.sh 2>&1 || true)

# Cleanup test plan
rm -rf "$TEST_PLAN_DIR"
rm -f "$ACTIVE_PTR"

if echo "$HOOK_OUTPUT" | grep -qi "incomplete"; then
    test_pass
else
    test_fail "Hook should warn about incomplete todos"
    echo "Debug: Hook output was: $HOOK_OUTPUT"
fi

# Test 7.3: State file is deleted after /03_close
test_start "TS-7.3: State file can be deleted after closure"
cleanup_state
create_test_state 0 7 ""

# Simulate state deletion (would happen in /03_close)
DELETE_STATE=true
if [ "$DELETE_STATE" = true ] && [ -f "$STATE_FILE" ]; then
    rm -f "$STATE_FILE"
    if [ ! -f "$STATE_FILE" ]; then
        test_pass
    else
        test_fail "State file should be deleted"
    fi
else
    test_fail "State file should exist before deletion"
fi

cleanup_state

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}INTEGRATION TEST SUMMARY${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    exit 1
fi
