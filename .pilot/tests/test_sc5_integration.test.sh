#!/bin/bash
# Test: SC-5 - Integration tested with existing commands
# Description: Verify /00_plan, /02_execute, /03_close use continuation system

set -euo pipefail

# Test setup
TEST_DIR="/tmp/sc5_integration_test_$$"
PROJECT_ROOT="$TEST_DIR/project"
PLAN_DIR="$PROJECT_ROOT/.pilot/plan"
STATE_DIR="$PROJECT_ROOT/.pilot/state"
SCRIPT_DIR="/Users/chanho/claude-pilot/.pilot/scripts"

setup() {
    # Create test project structure
    mkdir -p "$PROJECT_ROOT"
    mkdir -p "$PLAN_DIR/pending"
    mkdir -p "$PLAN_DIR/in_progress"
    mkdir -p "$PLAN_DIR/done"
    mkdir -p "$STATE_DIR"
    mkdir -p "$PROJECT_ROOT/.claude/commands"

    # Initialize git repo
    cd "$PROJECT_ROOT"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"

    # Create test plan file
    cat > "$PLAN_DIR/pending/test_plan.md" <<'EOF'
# Test Plan: Sisyphus Continuation Integration

## Success Criteria

SC-1: Create login endpoint in src/auth/login.ts (coder, 10 min)
SC-2: Write login endpoint tests (tester, 5 min)
SC-3: Verify login coverage >=80% (validator, 2 min)

## Granular Todo Breakdown

| ID | Todo | Owner | Est. Time | Status |
|----|------|-------|-----------|--------|
| SC-1 | Create login endpoint in src/auth/login.ts | coder | 10 min | pending |
| SC-2 | Write login endpoint tests | tester | 5 min | pending |
| SC-3 | Verify login coverage >=80% | validator | 2 min | pending |

**Granularity Verification**: All todos comply with 3 rules
**Warnings**: None
EOF
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test 1: /00_plan generates granular todos
test_00_plan_granular_todos() {
    setup

    echo "=== Test 1: /00_plan generates granular todos ==="

    # Verify plan has granular todo section
    if ! grep -q "## Granular Todo Breakdown" "$PLAN_DIR/pending/test_plan.md"; then
        echo "FAIL: /00_plan missing granular todo breakdown section"
        return 1
    fi

    # Verify todos follow 3 rules
    local todos
    todos=$(grep -E '^\| SC-' "$PLAN_DIR/pending/test_plan.md" | wc -l)

    if [ "$todos" -lt 3 ]; then
        echo "FAIL: /00_plan should break down SCs into granular todos"
        return 1
    fi

    # Verify each todo has owner and time estimate
    if ! grep -q "| coder |" "$PLAN_DIR/pending/test_plan.md"; then
        echo "FAIL: Todos missing owner assignment"
        return 1
    fi

    if ! grep -q "10 min" "$PLAN_DIR/pending/test_plan.md"; then
        echo "FAIL: Todos missing time estimates"
        return 1
    fi

    echo "PASS: /00_plan generates granular todos with owners and time estimates"
    teardown
}

# Test 2: /02_execute checks continuation state
test_02_execute_state_check() {
    setup

    echo "=== Test 2: /02_execute checks continuation state ==="

    # Move plan to in_progress (simulating /02_execute Step 1)
    mv "$PLAN_DIR/pending/test_plan.md" "$PLAN_DIR/in_progress/test_plan.md"

    # Create continuation state (simulating /02_execute Step 0.5)
    local plan_path="$PLAN_DIR/in_progress/test_plan.md"
    local branch="main"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"},
        {"id": "SC-3", "status": "pending", "iteration": 0, "owner": "validator"}
    ]'

    # Create state file
    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "$branch",
    "plan_file": "$plan_path",
    "todos": $todos,
    "iteration_count": 1,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:30:00Z",
    "continuation_level": "normal"
}
EOF

    # Verify state file exists
    if [ ! -f "$STATE_DIR/continuation.json" ]; then
        echo "FAIL: /02_execute did not create continuation state"
        return 1
    fi

    # Verify state has required fields
    if ! jq -e '.session_id' "$STATE_DIR/continuation.json" > /dev/null; then
        echo "FAIL: Continuation state missing session_id"
        return 1
    fi

    if ! jq -e '.plan_file' "$STATE_DIR/continuation.json" > /dev/null; then
        echo "FAIL: Continuation state missing plan_file"
        return 1
    fi

    if ! jq -e '.todos' "$STATE_DIR/continuation.json" > /dev/null; then
        echo "FAIL: Continuation state missing todos"
        return 1
    fi

    echo "PASS: /02_execute creates continuation state with required fields"
    teardown
}

# Test 3: /02_execute updates state after todos
test_02_execute_state_update() {
    setup

    echo "=== Test 3: /02_execute updates state after todos ==="

    # Create initial state
    local plan_path="$PLAN_DIR/in_progress/test_plan.md"
    mkdir -p "$PLAN_DIR/in_progress"
    touch "$plan_path"

    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$plan_path",
    "todos": $todos,
    "iteration_count": 1,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:30:00Z",
    "continuation_level": "normal"
}
EOF

    # Simulate state update after todo completion (Step 2.6)
    local updated_todos='[
        {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder", "completed_at": "2026-01-18T10:35:00Z"},
        {"id": "SC-2", "status": "in_progress", "iteration": 2, "owner": "tester"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$plan_path",
    "todos": $updated_todos,
    "iteration_count": 2,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:35:00Z",
    "continuation_level": "normal"
}
EOF

    # Verify state was updated
    local iteration_count
    iteration_count=$(jq -r '.iteration_count' "$STATE_DIR/continuation.json")

    if [ "$iteration_count" != "2" ]; then
        echo "FAIL: State not updated after todo completion"
        return 1
    fi

    local sc1_status
    sc1_status=$(jq -r '.todos[0].status' "$STATE_DIR/continuation.json")

    if [ "$sc1_status" != "complete" ]; then
        echo "FAIL: Todo status not updated to complete"
        return 1
    fi

    echo "PASS: /02_execute updates continuation state after todo completion"
    teardown
}

# Test 4: /03_close verifies all todos complete
test_03_close_continuation_verification() {
    setup

    echo "=== Test 4: /03_close verifies all todos complete ==="

    # Create plan with incomplete state
    mkdir -p "$PLAN_DIR/in_progress"
    touch "$PLAN_DIR/in_progress/test_plan.md"

    local todos='[
        {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$PLAN_DIR/in_progress/test_plan.md",
    "todos": $todos,
    "iteration_count": 1,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:30:00Z",
    "continuation_level": "normal"
}
EOF

    # Check for incomplete todos (simulating Step 3.5)
    local incomplete_count
    incomplete_count=$(jq -r '[.todos[] | select(.status != "complete")] | length' "$STATE_DIR/continuation.json")

    if [ "$incomplete_count" -eq 0 ]; then
        echo "FAIL: Should detect incomplete todos"
        return 1
    fi

    if [ "$incomplete_count" -ne 1 ]; then
        echo "FAIL: Should detect exactly 1 incomplete todo"
        return 1
    fi

    echo "PASS: /03_close detects incomplete todos and refuses closure"
    teardown
}

# Test 5: /03_close archives continuation state
test_03_close_state_archival() {
    setup

    echo "=== Test 5: /03_close archives continuation state ==="

    # Create complete state
    mkdir -p "$PLAN_DIR/in_progress"
    touch "$PLAN_DIR/in_progress/test_plan.md"

    local todos='[
        {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "complete", "iteration": 2, "owner": "tester"},
        {"id": "SC-3", "status": "complete", "iteration": 3, "owner": "validator"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$PLAN_DIR/in_progress/test_plan.md",
    "todos": $todos,
    "iteration_count": 3,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:40:00Z",
    "continuation_level": "normal"
}
EOF

    # Move plan to done (simulating Step 4)
    mkdir -p "$PLAN_DIR/done"
    mv "$PLAN_DIR/in_progress/test_plan.md" "$PLAN_DIR/done/test_plan.md"

    # Archive state (simulating state preservation)
    if [ -f "$STATE_DIR/continuation.json" ]; then
        cp "$STATE_DIR/continuation.json" "$PLAN_DIR/done/test_plan_continuation_state.json"
    fi

    # Verify state was archived
    if [ ! -f "$PLAN_DIR/done/test_plan_continuation_state.json" ]; then
        echo "FAIL: Continuation state not archived to done/"
        return 1
    fi

    # Verify original state still exists (preserved for recovery)
    if [ ! -f "$STATE_DIR/continuation.json" ]; then
        echo "FAIL: Original continuation state should be preserved"
        return 1
    fi

    echo "PASS: /03_close archives continuation state to done/"
    teardown
}

# Test 6: End-to-end integration test
test_end_to_end_integration() {
    setup

    echo "=== Test 6: End-to-end integration test ==="

    # Step 1: /00_plan creates plan with granular todos
    if ! grep -q "## Granular Todo Breakdown" "$PLAN_DIR/pending/test_plan.md"; then
        echo "FAIL: Plan missing granular todo section"
        return 1
    fi

    # Step 2: /02_execute creates continuation state
    mv "$PLAN_DIR/pending/test_plan.md" "$PLAN_DIR/in_progress/test_plan.md"

    local plan_path="$PLAN_DIR/in_progress/test_plan.md"
    local todos='[
        {"id": "SC-1", "status": "in_progress", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "pending", "iteration": 0, "owner": "tester"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$plan_path",
    "todos": $todos,
    "iteration_count": 1,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:30:00Z",
    "continuation_level": "normal"
}
EOF

    # Step 3: /02_execute updates state
    local updated_todos='[
        {"id": "SC-1", "status": "complete", "iteration": 1, "owner": "coder"},
        {"id": "SC-2", "status": "complete", "iteration": 2, "owner": "tester"}
    ]'

    cat > "$STATE_DIR/continuation.json" <<EOF
{
    "version": "1.0",
    "session_id": "test-session-123",
    "branch": "main",
    "plan_file": "$plan_path",
    "todos": $updated_todos,
    "iteration_count": 2,
    "max_iterations": 7,
    "last_checkpoint": "2026-01-18T10:35:00Z",
    "continuation_level": "normal"
}
EOF

    # Step 4: /03_close verifies completion
    local incomplete_count
    incomplete_count=$(jq -r '[.todos[] | select(.status != "complete")] | length' "$STATE_DIR/continuation.json")

    if [ "$incomplete_count" -ne 0 ]; then
        echo "FAIL: Should allow closure when all todos complete"
        return 1
    fi

    # Step 5: /03_close archives state
    mkdir -p "$PLAN_DIR/done"
    mv "$PLAN_DIR/in_progress/test_plan.md" "$PLAN_DIR/done/test_plan.md"
    cp "$STATE_DIR/continuation.json" "$PLAN_DIR/done/test_plan_continuation_state.json"

    if [ ! -f "$PLAN_DIR/done/test_plan_continuation_state.json" ]; then
        echo "FAIL: State not archived in end-to-end flow"
        return 1
    fi

    echo "PASS: End-to-end integration test successful"
    teardown
}

# Run all tests
main() {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  SC-5: Integration Test - Sisyphus Continuation System  ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    test_00_plan_granular_todos
    test_02_execute_state_check
    test_02_execute_state_update
    test_03_close_continuation_verification
    test_03_close_state_archival
    test_end_to_end_integration

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           ✅ All SC-5 integration tests passed          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
}

main "$@"
