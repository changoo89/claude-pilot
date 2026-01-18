#!/bin/bash
# Test: TS-6 - /00_continue command resume workflow
# Description: Verify /00_continue resumes work from continuation state

set -euo pipefail

# Test setup
TEST_DIR="/tmp/continue_test_$$"
STATE_DIR="$TEST_DIR/state"
COMMAND_FILE="$TEST_DIR/00_continue.md"
SCRIPT_DIR="/Users/chanho/claude-pilot/.pilot/scripts"

setup() {
    mkdir -p "$STATE_DIR"
    mkdir -p "$(dirname "$COMMAND_FILE")"
}

teardown() {
    rm -rf "$TEST_DIR"
}

test_continue_command_file_exists() {
    # Verify command file exists
    [ -f "/Users/chanho/claude-pilot/.claude/commands/00_continue.md" ] || {
        echo "FAIL: /00_continue command file does not exist"
        return 1
    }

    echo "PASS: /00_continue command file exists"
}

test_continue_command_structure() {
    # Verify command has required sections
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    # Check for required headers
    grep -q "# /00_continue" "$command_file" || {
        echo "FAIL: Missing command title"
        return 1
    }

    grep -q "## Step 1: Check Continuation State" "$command_file" || {
        echo "FAIL: Missing Step 1 section"
        return 1
    }

    grep -q "## Step 2: Load State" "$command_file" || {
        echo "FAIL: Missing Step 2 section"
        return 1
    }

    grep -q "## Step 3: Validate State" "$command_file" || {
        echo "FAIL: Missing Step 3 section"
        return 1
    }

    grep -q "## Step 4: Resume Work" "$command_file" || {
        echo "FAIL: Missing Step 4 section"
        return 1
    }

    grep -q "## Step 5: Continue Execution" "$command_file" || {
        echo "FAIL: Missing Step 5 section"
        return 1
    }

    echo "PASS: /00_continue command structure valid"
}

test_continue_command_has_state_read_integration() {
    # Verify command integrates with state_read.sh
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "state_read.sh" "$command_file" || {
        echo "FAIL: Missing state_read.sh integration"
        return 1
    }

    echo "PASS: /00_continue integrates with state_read.sh"
}

test_continue_command_has_state_write_integration() {
    # Verify command integrates with state_write.sh
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "state_write.sh" "$command_file" || {
        echo "FAIL: Missing state_write.sh integration"
        return 1
    }

    echo "PASS: /00_continue integrates with state_write.sh"
}

test_continue_command_checks_continuation_json() {
    # Verify command checks for continuation.json
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "continuation.json" "$command_file" || {
        echo "FAIL: Missing continuation.json check"
        return 1
    }

    echo "PASS: /00_continue checks continuation.json"
}

test_continue_command_validates_branch() {
    # Verify command validates branch matches
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "branch" "$command_file" || {
        echo "FAIL: Missing branch validation"
        return 1
    }

    echo "PASS: /00_continue validates branch"
}

test_continue_command_validates_plan_file() {
    # Verify command validates plan file exists
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "plan_file" "$command_file" || {
        echo "FAIL: Missing plan file validation"
        return 1
    }

    echo "PASS: /00_continue validates plan file"
}

test_continue_command_checks_iteration_limit() {
    # Verify command checks iteration count
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "iteration" "$command_file" || {
        echo "FAIL: Missing iteration limit check"
        return 1
    }

    echo "PASS: /00_continue checks iteration limit"
}

test_continue_command_resumes_next_todo() {
    # Verify command finds next incomplete todo
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "incomplete" "$command_file" || {
        echo "FAIL: Missing logic to find next incomplete todo"
        return 1
    }

    echo "PASS: /00_continue resumes next incomplete todo"
}

test_continue_command_updates_checkpoint() {
    # Verify command updates checkpoint on progress
    local command_file="/Users/chanho/claude-pilot/.claude/commands/00_continue.md"

    grep -q "checkpoint" "$command_file" || {
        echo "FAIL: Missing checkpoint update logic"
        return 1
    }

    echo "PASS: /00_continue updates checkpoint"
}

# Run tests
main() {
    echo "=== TS-6: /00_continue Command Tests ==="

    test_continue_command_file_exists
    test_continue_command_structure
    test_continue_command_has_state_read_integration
    test_continue_command_has_state_write_integration
    test_continue_command_checks_continuation_json
    test_continue_command_validates_branch
    test_continue_command_validates_plan_file
    test_continue_command_checks_iteration_limit
    test_continue_command_resumes_next_todo
    test_continue_command_updates_checkpoint

    echo "=== All TS-6 tests passed ==="
}

main "$@"
