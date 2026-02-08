#!/bin/bash
# Hook: TaskCompleted
# Purpose: Verify quality gates before allowing task completion
# Exit 0: allow completion | Exit 2: reject with feedback
#
# Usage: Called automatically by Claude Code Agent Teams when teammate marks task as done
# Environment: TASK_DESCRIPTION, PLAN_PATH
#
# Quality Gates:
# 1. Tests pass (auto-detect: npm test, pytest, cargo test, go test)
# 2. Coverage ≥80%
# 3. Type-check clean (tsc --noEmit if applicable)
# 4. Lint clean (if applicable)
# 5. TODO checkboxes checked in plan file

set -euo pipefail

# Configuration
TIMEOUT_SECONDS=120
MIN_COVERAGE=80

# Detect test runner
detect_test_runner() {
    if [ -f "package.json" ]; then
        echo "npm test"
    elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        echo "pytest"
    elif [ -f "Cargo.toml" ]; then
        echo "cargo test"
    elif [ -f "go.mod" ]; then
        echo "go test ./..."
    else
        echo ""
    fi
}

# Run tests with timeout
run_tests() {
    local test_cmd="$1"

    if [ -z "$test_cmd" ]; then
        echo "Warning: No test runner detected, skipping test check" >&2
        return 0
    fi

    echo "Running tests: $test_cmd" >&2
    if timeout "$TIMEOUT_SECONDS" $test_cmd >/dev/null 2>&1; then
        return 0
    else
        echo "ERROR: Tests failed or timed out" >&2
        return 1
    fi
}

# Check coverage
check_coverage() {
    local test_cmd="$1"

    if [ -z "$test_cmd" ]; then
        return 0
    fi

    echo "Checking coverage..." >&2

    # Extract coverage based on test runner
    if [[ "$test_cmd" == "npm test" ]]; then
        local coverage_output=$(npm test -- --coverage 2>&1 || true)
        local coverage=$(echo "$coverage_output" | grep -oE 'Lines[[:space:]]*:[[:space:]]*[0-9.]+' | grep -oE '[0-9.]+' | head -1)

        if [ -n "$coverage" ]; then
            if (( $(echo "$coverage < $MIN_COVERAGE" | bc -l 2>/dev/null || echo 0) )); then
                echo "ERROR: Coverage $coverage% < $MIN_COVERAGE%" >&2
                return 1
            fi
        fi
    elif [[ "$test_cmd" == "pytest" ]]; then
        local coverage_output=$(pytest --cov 2>&1 || true)
        local coverage=$(echo "$coverage_output" | grep -oE 'TOTAL[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+%' | grep -oE '[0-9]+%' | grep -oE '[0-9]+')

        if [ -n "$coverage" ]; then
            if (( coverage < MIN_COVERAGE )); then
                echo "ERROR: Coverage ${coverage}% < $MIN_COVERAGE%" >&2
                return 1
            fi
        fi
    fi

    return 0
}

# Type-check
check_types() {
    if [ -f "tsconfig.json" ] && command -v tsc >/dev/null 2>&1; then
        echo "Running type-check..." >&2
        if ! tsc --noEmit 2>&1; then
            echo "ERROR: Type-check failed" >&2
            return 1
        fi
    fi
    return 0
}

# Lint check
check_lint() {
    if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
        if npm run lint --if-present >/dev/null 2>&1; then
            return 0
        else
            # Only fail if lint script exists and fails
            if npm run lint --if-present 2>&1 | grep -q "Missing script"; then
                return 0
            fi
            echo "ERROR: Lint check failed" >&2
            return 1
        fi
    fi
    return 0
}

# Check TODOs in plan
check_todos() {
    local plan_file="${PLAN_PATH:-}"

    if [ -z "$plan_file" ]; then
        # Auto-detect plan file
        plan_file=$(find .pilot/plan/in_progress -name "*.md" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
        echo "Warning: No plan file found, skipping TODO check" >&2
        return 0
    fi

    echo "Checking TODOs in $plan_file..." >&2

    if grep -q "^- \[ \]" "$plan_file"; then
        echo "ERROR: Unchecked TODOs found in plan file" >&2
        grep "^- \[ \]" "$plan_file" >&2
        return 1
    fi

    return 0
}

# Main execution
main() {
    local test_cmd
    test_cmd=$(detect_test_runner)

    # Run all quality gates
    if ! run_tests "$test_cmd"; then
        exit 2
    fi

    if ! check_coverage "$test_cmd"; then
        exit 2
    fi

    if ! check_types; then
        exit 2
    fi

    if ! check_lint; then
        exit 2
    fi

    if ! check_todos; then
        exit 2
    fi

    echo "✓ All quality gates passed" >&2
    exit 0
}

main "$@"
