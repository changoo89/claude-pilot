#!/bin/bash
# Test: TS-4 - State file corruption handling
# Description: Verify backup/recovery when continuation.json is corrupted

set -euo pipefail

# Test setup
TEST_DIR="/tmp/state_recovery_test_$$"
STATE_DIR="$TEST_DIR/state"
SCRIPT_DIR="/Users/chanho/claude-pilot/.pilot/scripts"

setup() {
    mkdir -p "$STATE_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

test_corrupted_json_detection() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'

    # Create valid state first
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Corrupt the JSON file
    echo "{invalid json content" > "$STATE_DIR/continuation.json"

    # Attempt to read corrupted state
    if bash "$SCRIPT_DIR/state_read.sh" 2>/dev/null; then
        echo "FAIL: Should have rejected corrupted JSON"
        return 1
    fi

    echo "PASS: Corrupted JSON detected and rejected"
}

test_backup_recovery_on_corruption() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'

    # Create valid state (iteration 1)
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1

    # Save original content for verification
    local original_content
    original_content=$(cat "$STATE_DIR/continuation.json")

    # Write again (iteration 2) - this should create backup
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 2

    # Verify backup exists
    if [ ! -f "$STATE_DIR/continuation.json.backup" ]; then
        echo "FAIL: Backup file not created on second write"
        return 1
    fi

    # Verify backup has iteration 1 content
    local backup_iteration
    backup_iteration=$(jq -r '.iteration_count' "$STATE_DIR/continuation.json.backup")

    if [ "$backup_iteration" != "1" ]; then
        echo "FAIL: Backup should have iteration 1, got $backup_iteration"
        return 1
    fi

    # Now corrupt the primary file
    echo "{invalid json content" > "$STATE_DIR/continuation.json"

    # Read should fail
    if bash "$SCRIPT_DIR/state_read.sh" 2>/dev/null; then
        echo "FAIL: Should have rejected corrupted JSON"
        return 1
    fi

    # Verify backup still exists and is valid
    if [ ! -f "$STATE_DIR/continuation.json.backup" ]; then
        echo "FAIL: Backup file should still exist"
        return 1
    fi

    # Verify backup is still valid JSON
    if ! jq empty "$STATE_DIR/continuation.json.backup" 2>/dev/null; then
        echo "FAIL: Backup file is corrupted"
        return 1
    fi

    echo "PASS: Backup preserved when primary file corrupted"
}

test_invalid_todos_json_rejection() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local invalid_todos='[invalid json]'

    # Attempt to write with invalid todos JSON
    export STATE_DIR="$STATE_DIR"
    if bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$invalid_todos" \
        --iteration 1 2>/dev/null; then
        echo "FAIL: Should have rejected invalid todos JSON"
        return 1
    fi

    # Verify no state file was created
    if [ -f "$STATE_DIR/continuation.json" ]; then
        echo "FAIL: State file should not exist with invalid todos"
        return 1
    fi

    echo "PASS: Invalid todos JSON rejected"
}

test_directory_creation_on_write() {
    local plan_file=".pilot/plan/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"}
    ]'

    # Remove state directory
    rm -rf "$STATE_DIR"

    # Write should create directory
    export STATE_DIR="$STATE_DIR"
    bash "$SCRIPT_DIR/state_write.sh" \
        --plan-file "$plan_file" \
        --todos "$todos" \
        --iteration 1 2>/dev/null

    if [ ! -d "$STATE_DIR" ]; then
        echo "FAIL: State directory not created"
        return 1
    fi

    if [ ! -f "$STATE_DIR/continuation.json" ]; then
        echo "FAIL: continuation.json not created"
        return 1
    fi

    echo "PASS: Directory created automatically"
}

# Run tests
main() {
    setup

    echo "=== TS-4: State File Corruption Handling Tests ==="

    test_corrupted_json_detection
    teardown
    setup

    test_backup_recovery_on_corruption
    teardown
    setup

    test_invalid_todos_json_rejection
    teardown
    setup

    test_directory_creation_on_write

    teardown

    echo "=== All TS-4 tests passed ==="
}

main "$@"
