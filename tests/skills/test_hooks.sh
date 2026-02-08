#!/bin/bash
# Test suite for Agent Teams hook scripts
# Tests both verify-task-completion.sh and teammate-idle-check.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.claude/hooks"

# Test counters
PASS=0
FAIL=0
SKIP=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper
assert_exit_code() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if [ "$expected" -eq "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $test_name (expected: $expected, got: $actual)"
        ((FAIL++))
    fi
}

assert_output_contains() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if echo "$actual" | grep -q "$expected"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $test_name (expected to contain: $expected)"
        ((FAIL++))
    fi
}

# Setup test fixtures
setup_test_env() {
    export TEST_DIR=$(mktemp -d)
    export PLAN_PATH="$TEST_DIR/plan.md"

    # Create dummy test commands that can be overridden
    export PATH="$TEST_DIR/bin:$PATH"
    mkdir -p "$TEST_DIR/bin"

    # Create package.json for npm detection
    cat > "$TEST_DIR/package.json" <<'EOF'
{"name": "test", "version": "1.0.0"}
EOF

    # Create default passing test command
    cat > "$TEST_DIR/bin/npm" <<'EOF'
#!/bin/bash
if [[ "$*" == "test" ]]; then
    echo "PASS 5 tests"
    exit 0
elif [[ "$*" == *"--coverage"* ]]; then
    echo "Lines: 85.5%"
    exit 0
elif [[ "$*" == "run lint --if-present" ]]; then
    echo "Missing script: lint"
    exit 0
fi
exit 0
EOF
    chmod +x "$TEST_DIR/bin/npm"

    cat > "$TEST_DIR/bin/tsc" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$TEST_DIR/bin/tsc"

    cat > "$TEST_DIR/bin/bc" <<'EOF'
#!/bin/bash
echo "1"
EOF
    chmod +x "$TEST_DIR/bin/bc"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Test: verify-task-completion.sh syntax check
test_verify_completion_syntax() {
    bash -n "$HOOKS_DIR/verify-task-completion.sh" 2>/dev/null
    assert_exit_code 0 $? "verify-task-completion.sh syntax check"
}

# Test: verify-task-completion.sh is executable
test_verify_completion_executable() {
    [ -x "$HOOKS_DIR/verify-task-completion.sh" ]
    assert_exit_code 0 $? "verify-task-completion.sh is executable"
}

# Test: verify-task-completion.sh with passing tests
test_verify_completion_passing() {
    setup_test_env

    # Create plan with all TODOs checked
    cat > "$PLAN_PATH" <<EOF
# Test Plan
- [x] SC-1: Complete
- [x] SC-2: Complete
EOF

    # Run hook in test dir (should pass)
    (cd "$TEST_DIR" && PLAN_PATH="$PLAN_PATH" timeout 10 "$HOOKS_DIR/verify-task-completion.sh" >/dev/null 2>&1)
    assert_exit_code 0 $? "verify-task-completion.sh passes with all checks passing"

    cleanup_test_env
}

# Test: verify-task-completion.sh with unchecked TODOs
test_verify_completion_unchecked_todos() {
    setup_test_env

    # Create plan with unchecked TODOs
    cat > "$PLAN_PATH" <<EOF
# Test Plan
- [ ] SC-1: Incomplete
- [x] SC-2: Complete
EOF

    # Run hook (should fail with exit 2)
    (cd "$TEST_DIR" && PLAN_PATH="$PLAN_PATH" timeout 10 "$HOOKS_DIR/verify-task-completion.sh" 2>&1) | grep -q "TODO" || true
    local result=${PIPESTATUS[0]:-0}

    # We expect exit code 2 for rejection
    if [ "$result" -eq 2 ]; then
        assert_exit_code 2 2 "verify-task-completion.sh rejects unchecked TODOs"
    else
        assert_exit_code 2 0 "verify-task-completion.sh rejects unchecked TODOs"
    fi

    cleanup_test_env
}

# Test: verify-task-completion.sh with failing tests
test_verify_completion_failing_tests() {
    setup_test_env

    # Override npm to fail tests
    cat > "$TEST_DIR/bin/npm" <<'EOF'
#!/bin/bash
echo "FAIL test suite"
exit 1
EOF
    chmod +x "$TEST_DIR/bin/npm"

    # Create package.json to trigger npm test
    cat > "$TEST_DIR/package.json" <<'EOF'
{"name": "test"}
EOF

    cat > "$PLAN_PATH" <<EOF
- [x] SC-1: Complete
EOF

    # Run hook (should fail)
    (cd "$TEST_DIR" && PLAN_PATH="$PLAN_PATH" timeout 10 "$HOOKS_DIR/verify-task-completion.sh" >/dev/null 2>&1) || true
    local result=$?

    assert_exit_code 2 "$result" "verify-task-completion.sh rejects failing tests"

    cleanup_test_env
}

# Test: teammate-idle-check.sh syntax check
test_idle_check_syntax() {
    bash -n "$HOOKS_DIR/teammate-idle-check.sh" 2>/dev/null
    assert_exit_code 0 $? "teammate-idle-check.sh syntax check"
}

# Test: teammate-idle-check.sh is executable
test_idle_check_executable() {
    [ -x "$HOOKS_DIR/teammate-idle-check.sh" ]
    assert_exit_code 0 $? "teammate-idle-check.sh is executable"
}

# Test: teammate-idle-check.sh with complete work
test_idle_check_complete() {
    setup_test_env

    # Create plan with all TODOs checked
    cat > "$PLAN_PATH" <<EOF
# Test Plan
- [x] SC-1: Complete
EOF

    # Create package.json to avoid test runner detection
    cat > "$TEST_DIR/package.json" <<'EOF'
{"name": "test"}
EOF

    # Run hook (should allow idle)
    (cd "$TEST_DIR" && PLAN_PATH="$PLAN_PATH" timeout 10 "$HOOKS_DIR/teammate-idle-check.sh" >/dev/null 2>&1)
    assert_exit_code 0 $? "teammate-idle-check.sh allows idle with complete work"

    cleanup_test_env
}

# Test: teammate-idle-check.sh with incomplete work
test_idle_check_incomplete() {
    setup_test_env

    # Create plan with unchecked TODOs
    cat > "$PLAN_PATH" <<EOF
# Test Plan
- [ ] SC-1: Incomplete
EOF

    # Run hook (should reject idle)
    (cd "$TEST_DIR" && PLAN_PATH="$PLAN_PATH" "$HOOKS_DIR/teammate-idle-check.sh" 2>&1) | grep -q "incomplete" || true
    local result=${PIPESTATUS[0]:-0}

    # We expect exit code 2 for rejection
    if [ "$result" -eq 2 ]; then
        assert_exit_code 2 2 "teammate-idle-check.sh rejects idle with incomplete work"
    else
        assert_exit_code 2 0 "teammate-idle-check.sh rejects idle with incomplete work"
    fi

    cleanup_test_env
}

# Run all tests
echo "Running hook script tests..."
echo

test_verify_completion_syntax
test_verify_completion_executable
test_verify_completion_passing
test_verify_completion_unchecked_todos
test_verify_completion_failing_tests

test_idle_check_syntax
test_idle_check_executable
test_idle_check_complete
test_idle_check_incomplete

# Summary
echo
echo "============================================"
echo "Test Results:"
echo -e "${GREEN}PASS: $PASS${NC} | ${RED}FAIL: $FAIL${NC} | ${YELLOW}SKIP: $SKIP${NC}"
echo "============================================"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
