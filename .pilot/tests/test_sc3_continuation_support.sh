#!/bin/bash
# Test: TS-3 - Continuation Support for /04_fix
# Description: Verify /04_fix creates continuation state and supports resume via /00_continue

set -euo pipefail

# Test paths
TEST_DIR="/tmp/fix_continuation_test_$$"
STATE_DIR="$TEST_DIR/.pilot/state"
PLAN_DIR="$TEST_DIR/.pilot/plan/in_progress"
SCRIPT_DIR="/Users/chanho/claude-pilot/.pilot/scripts"
SOURCE_DIR="/Users/chanho/claude-pilot"

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
setup() {
    mkdir -p "$STATE_DIR"
    mkdir -p "$PLAN_DIR"
    mkdir -p "$TEST_DIR/.claude/commands"
}

teardown() {
    rm -rf "$TEST_DIR"
}

assert_file_exists() {
    local file="$1"
    local description="${2:-File exists}"

    ((TESTS_RUN++))
    if [ -f "$file" ]; then
        echo -e "${GREEN}PASS${NC}: $description"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}: $description - File not found: $file"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_json_field() {
    local file="$1"
    local field="$2"
    local description="${3:-JSON field exists: $field}"

    ((TESTS_RUN++))
    if jq -e ".$field" "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}: $description"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}: $description - Field not found"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_json_equals() {
    local file="$1"
    local field="$2"
    local expected="$3"
    local description="${4:-JSON field equals: $field = $expected}"

    ((TESTS_RUN++))
    local actual
    actual=$(jq -r ".$field" "$file")
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}PASS${NC}: $description"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}: $description - Expected '$expected', got '$actual'"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_json_array_length() {
    local file="$1"
    local field="$2"
    local expected="$3"
    local description="${4:-JSON array length: $field has $expected items}"

    ((TESTS_RUN++))
    local actual
    actual=$(jq -r ".$field | length" "$file")
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}PASS${NC}: $description"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}: $description - Expected $expected, got $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test: Continuation state file creation
test_continuation_state_creation() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 0, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    # Simulate /04_fix creating continuation state
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 0

    # Verify continuation file created
    assert_file_exists "$STATE_DIR/continuation.json" "Continuation state file created"

    # Verify required fields exist
    assert_json_field "$STATE_DIR/continuation.json" "version" "Field 'version' exists"
    assert_json_field "$STATE_DIR/continuation.json" "session_id" "Field 'session_id' exists"
    assert_json_field "$STATE_DIR/continuation.json" "branch" "Field 'branch' exists"
    assert_json_field "$STATE_DIR/continuation.json" "plan_file" "Field 'plan_file' exists"
    assert_json_field "$STATE_DIR/continuation.json" "todos" "Field 'todos' exists"
    assert_json_field "$STATE_DIR/continuation.json" "iteration_count" "Field 'iteration_count' exists"
    assert_json_field "$STATE_DIR/continuation.json" "max_iterations" "Field 'max_iterations' exists"
    assert_json_field "$STATE_DIR/continuation.json" "last_checkpoint" "Field 'last_checkpoint' exists"
    assert_json_field "$STATE_DIR/continuation.json" "continuation_level" "Field 'continuation_level' exists"

    teardown
}

# Test: Continuation state has correct values
test_continuation_state_values() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    # Write state with specific values
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    local continuation_file="$STATE_DIR/continuation.json"

    # Verify specific values
    assert_json_equals "$continuation_file" "version" "1.0" "Version is 1.0"
    assert_json_equals "$continuation_file" "plan_file" "$plan_file" "Plan file path matches"
    assert_json_equals "$continuation_file" "iteration_count" "1" "Iteration count is 1"
    assert_json_equals "$continuation_file" "max_iterations" "7" "Max iterations is 7 (default)"
    assert_json_equals "$continuation_file" "continuation_level" "normal" "Continuation level is normal (default)"

    # Verify todos array length
    assert_json_array_length "$continuation_file" "todos" "2" "Todos array has 2 items"

    teardown
}

# Test: Continuation state updates on iteration
test_continuation_state_updates() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 0, "owner": "coder"}
    ]'

    export STATE_DIR="$STATE_DIR"

    # Initial state (iteration 0)
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 0

    local continuation_file="$STATE_DIR/continuation.json"
    assert_json_equals "$continuation_file" "iteration_count" "0" "Initial iteration count is 0"

    # Update state (iteration 1 - simulating Ralph Loop progress)
    todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    assert_json_equals "$continuation_file" "iteration_count" "1" "Updated iteration count is 1"

    # Update state (iteration 2 - more progress)
    todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 2, "owner": "coder"}
    ]'
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 2

    assert_json_equals "$continuation_file" "iteration_count" "2" "Updated iteration count is 2"

    teardown
}

# Test: Continuation state supports /00_continue resume
test_continuation_resume_support() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 3, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    # Create continuation state (simulating incomplete /04_fix execution)
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 3

    local continuation_file="$STATE_DIR/continuation.json"

    # Verify state can be read (simulating /00_continue reading state)
    if [ ! -f "$continuation_file" ]; then
        echo -e "${RED}FAIL${NC}: Continuation file not found for resume test"
        ((TESTS_FAILED++))
        ((TESTS_RUN++))
        teardown
        return 1
    fi

    # Read state using state_read.sh
    local read_output
    read_output=$(bash "$SCRIPT_DIR/state_read.sh")

    # Verify read output contains expected data
    local read_plan_file
    local read_iteration
    local read_todos_count

    read_plan_file=$(echo "$read_output" | jq -r '.plan_file')
    read_iteration=$(echo "$read_output" | jq -r '.iteration_count')
    read_todos_count=$(echo "$read_output" | jq -r '.todos | length')

    ((TESTS_RUN++))
    if [ "$read_plan_file" = "$plan_file" ] && [ "$read_iteration" = "3" ] && [ "$read_todos_count" = "2" ]; then
        echo -e "${GREEN}PASS${NC}: Continuation state readable for /00_continue resume"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: Continuation state not readable correctly"
        echo "  Expected plan_file: $plan_file, got: $read_plan_file"
        echo "  Expected iteration: 3, got: $read_iteration"
        echo "  Expected todos count: 2, got: $read_todos_count"
        ((TESTS_FAILED++))
    fi

    teardown
}

# Test: Max iteration safety
test_max_iteration_safety() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 6, "owner": "coder"}
    ]'

    export STATE_DIR="$STATE_DIR"

    # Create state at iteration 6 (near max)
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 6

    local continuation_file="$STATE_DIR/continuation.json"

    # Verify max_iterations is set
    assert_json_equals "$continuation_file" "max_iterations" "7" "Max iterations is 7"

    # Verify iteration_count is less than max_iterations (can continue)
    local iteration_count
    local max_iterations
    iteration_count=$(jq -r '.iteration_count' "$continuation_file")
    max_iterations=$(jq -r '.max_iterations' "$continuation_file")

    ((TESTS_RUN++))
    if [ "$iteration_count" -lt "$max_iterations" ]; then
        echo -e "${GREEN}PASS${NC}: Iteration count ($iteration_count) < max_iterations ($max_iterations) - can continue"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAIL${NC}: Iteration count ($iteration_count) >= max_iterations ($max_iterations) - should stop"
        ((TESTS_FAILED++))
    fi

    teardown
}

# Test: Continuation level configuration
test_continuation_level_config() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"}
    ]'

    # Test default continuation level
    export STATE_DIR="$STATE_DIR"
    unset CONTINUATION_LEVEL
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 0

    local continuation_file="$STATE_DIR/continuation.json"
    assert_json_equals "$continuation_file" "continuation_level" "normal" "Default continuation level is normal"

    # Test custom continuation level
    export CONTINUATION_LEVEL="aggressive"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 0

    assert_json_equals "$continuation_file" "continuation_level" "aggressive" "Custom continuation level is aggressive"

    unset CONTINUATION_LEVEL

    teardown
}

# Test: Backup created on state update
test_backup_on_update() {
    setup

    local plan_file=".pilot/plan/in_progress/fix_plan.md"
    local todos='[
        {"id": "SC-1", "status": "pending", "iteration": 0, "owner": "coder"}
    ]'

    export STATE_DIR="$STATE_DIR"

    # Initial state
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 0

    # Update state (should create backup)
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Verify backup exists
    assert_file_exists "$STATE_DIR/continuation.json.backup" "Backup file created on update"

    teardown
}

# Run all tests
main() {
    echo "=========================================="
    echo "TS-3: Continuation Support Test Suite"
    echo "=========================================="
    echo ""

    echo "Test 1: Continuation state file creation"
    echo "------------------------------------------"
    test_continuation_state_creation
    echo ""

    echo "Test 2: Continuation state has correct values"
    echo "------------------------------------------"
    test_continuation_state_values
    echo ""

    echo "Test 3: Continuation state updates on iteration"
    echo "------------------------------------------"
    test_continuation_state_updates
    echo ""

    echo "Test 4: Continuation state supports /00_continue resume"
    echo "------------------------------------------"
    test_continuation_resume_support
    echo ""

    echo "Test 5: Max iteration safety"
    echo "------------------------------------------"
    test_max_iteration_safety
    echo ""

    echo "Test 6: Continuation level configuration"
    echo "------------------------------------------"
    test_continuation_level_config
    echo ""

    echo "Test 7: Backup created on state update"
    echo "------------------------------------------"
    test_backup_on_update
    echo ""

    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total Tests: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
