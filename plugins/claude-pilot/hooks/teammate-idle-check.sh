#!/bin/bash
# Hook: TeammateIdle
# Purpose: Verify work completion before allowing teammate to go idle
# Exit 0: allow idle (work is done) | Exit 2: reject idle (continue working)
#
# Usage: Called automatically by Claude Code Agent Teams when teammate stops working
# Environment: PLAN_PATH
#
# Checks:
# 1. Assigned SC is fully complete (all TODOs checked)
# 2. Quality gates pass (basic verification)

set -euo pipefail

# Find plan file
find_plan_file() {
    local plan_file="${PLAN_PATH:-}"

    if [ -z "$plan_file" ]; then
        # Auto-detect plan file
        plan_file=$(find .pilot/plan/in_progress -name "*.md" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
        echo "Warning: No plan file found, allowing idle by default" >&2
        return 1
    fi

    echo "$plan_file"
}

# Check if assigned SC is complete
check_sc_complete() {
    local plan_file="$1"

    echo "Checking SC completion in $plan_file..." >&2

    # Check for unchecked TODOs
    if grep -q "^- \[ \]" "$plan_file"; then
        echo "ERROR: Work incomplete - unchecked TODOs found:" >&2
        grep "^- \[ \]" "$plan_file" | head -5 >&2
        echo >&2
        echo "Please complete all assigned tasks before going idle." >&2
        return 1
    fi

    return 0
}

# Basic quality gate check
check_quality_gates() {
    echo "Checking quality gates..." >&2

    # Detect test runner
    local test_cmd=""
    if [ -f "package.json" ]; then
        test_cmd="npm test"
    elif [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        test_cmd="pytest"
    elif [ -f "Cargo.toml" ]; then
        test_cmd="cargo test"
    elif [ -f "go.mod" ]; then
        test_cmd="go test ./..."
    fi

    # Run tests if test runner found
    if [ -n "$test_cmd" ]; then
        if ! timeout 120 $test_cmd >/dev/null 2>&1; then
            echo "ERROR: Tests are failing" >&2
            echo "Please fix failing tests before going idle." >&2
            return 1
        fi
    fi

    return 0
}

# Main execution
main() {
    local plan_file
    plan_file=$(find_plan_file)

    if [ -z "$plan_file" ]; then
        # No plan file found, allow idle
        exit 0
    fi

    # Check SC completion
    if ! check_sc_complete "$plan_file"; then
        exit 2
    fi

    # Check quality gates
    if ! check_quality_gates; then
        exit 2
    fi

    echo "✓ All work complete, idle allowed" >&2
    exit 0
}

main "$@"
