#!/bin/bash
# Test: TS-1 - Continuation state creation
# Description: Verify continuation.json is created and updated correctly

set -euo pipefail

# Test setup
TEST_DIR="/tmp/continuation_test_$$"
STATE_DIR="$TEST_DIR/state"
SCRIPT_DIR="/Users/chanho/claude-pilot/.pilot/scripts"

setup() {
    mkdir -p "$STATE_DIR"
    mkdir -p "$SCRIPT_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

test_continuation_file_creation() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    # Call state_write to create continuation file
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Verify file exists
    [ -f "$STATE_DIR/continuation.json" ] || {
        echo "FAIL: continuation.json not created"
        return 1
    }

    echo "PASS: continuation.json created"
}

test_continuation_json_schema() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    # Write state
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Read and validate JSON schema
    local content
    content=$(cat "$STATE_DIR/continuation.json")

    # Check required fields
    echo "$content" | jq -e '.version' > /dev/null || {
        echo "FAIL: Missing 'version' field"
        return 1
    }

    echo "$content" | jq -e '.session_id' > /dev/null || {
        echo "FAIL: Missing 'session_id' field"
        return 1
    }

    echo "$content" | jq -e '.branch' > /dev/null || {
        echo "FAIL: Missing 'branch' field"
        return 1
    }

    echo "$content" | jq -e '.plan_file' > /dev/null || {
        echo "FAIL: Missing 'plan_file' field"
        return 1
    }

    echo "$content" | jq -e '.todos' > /dev/null || {
        echo "FAIL: Missing 'todos' field"
        return 1
    }

    echo "$content" | jq -e '.iteration_count' > /dev/null || {
        echo "FAIL: Missing 'iteration_count' field"
        return 1
    }

    echo "$content" | jq -e '.max_iterations' > /dev/null || {
        echo "FAIL: Missing 'max_iterations' field"
        return 1
    }

    echo "$content" | jq -e '.last_checkpoint' > /dev/null || {
        echo "FAIL: Missing 'last_checkpoint' field"
        return 1
    }

    echo "$content" | jq -e '.continuation_level' > /dev/null || {
        echo "FAIL: Missing 'continuation_level' field"
        return 1
    }

    echo "PASS: JSON schema valid"
}

test_continuation_read_write() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'

    # Write state
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 2

    # Read state
    local read_output
    read_output=$(bash "$SCRIPT_DIR/state_read.sh")

    # Verify read output
    echo "$read_output" | jq -e '.iteration_count == 2' > /dev/null || {
        echo "FAIL: iteration_count not read correctly"
        return 1
    }

    echo "$read_output" | jq -e '.plan_file == "'"$plan_file"'"' > /dev/null || {
        echo "FAIL: plan_file not read correctly"
        return 1
    }

    echo "PASS: Read/write cycle works"
}

test_backup_before_write() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'

    # Create initial state
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Update state (should create backup)
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 2

    # Verify backup exists
    [ -f "$STATE_DIR/continuation.json.backup" ] || {
        echo "FAIL: Backup file not created"
        return 1
    }

    echo "PASS: Backup created before write"
}

# Run tests
main() {
    setup

    echo "=== TS-1: Continuation State Creation Tests ==="

    test_continuation_file_creation
    teardown
    setup

    test_continuation_json_schema
    teardown
    setup

    test_continuation_read_write
    teardown
    setup

    test_backup_before_write

    teardown

    echo "=== All TS-1 tests passed ==="
}

main "$@"
