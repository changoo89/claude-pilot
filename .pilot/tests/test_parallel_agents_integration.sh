#!/usr/bin/env bash
# Test suite for Parallel Agents Integration plan
# Tests: SC-1 through SC-5

set -euo pipefail

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test results array
declare -a FAILED_TESTS

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper functions
test_start() {
    local test_name="$1"
    echo "Test: $test_name"
    ((TESTS_RUN++)) || true
}

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    local reason="$1"
    echo -e "${RED}✗ FAIL: $reason${NC}"
    ((TESTS_FAILED++)) || true
    FAILED_TESTS+=("$1")
}

# Change to plugin root
cd "$(dirname "$0")/../.."

# ============================================================================
# SC-1: Strengthen parallel-subagents skill and integrate into commands
# ============================================================================
test_sc1_commands_have_parallel_reference() {
    test_start "SC-1: All target commands reference parallel-subagents"

    local missing=""
    for f in 00_plan 02_execute review 03_close 05_cleanup; do
        if ! grep -q "parallel-subagents" ".claude/commands/${f}.md" 2>/dev/null; then
            missing="${missing} ${f}"
        fi
    done

    if [ -n "$missing" ]; then
        test_fail "Commands missing parallel-subagents reference:${missing}"
    else
        test_pass
    fi
}

test_sc1_skill_has_command_patterns() {
    test_start "SC-1: parallel-subagents skill has Command-Specific Patterns"

    if grep -q "Command-Specific Patterns" ".claude/skills/parallel-subagents/SKILL.md" 2>/dev/null; then
        test_pass
    else
        test_fail "Command-Specific Patterns section not found"
    fi
}

# ============================================================================
# SC-2: Add multi-coder parallel execution pattern to 02_execute.md
# ============================================================================
test_sc2_multi_coder_pattern() {
    test_start "SC-2: 02_execute.md has 4+ Task: invocations (multi-coder pattern)"

    local count
    count=$(grep -c "Task:" ".claude/commands/02_execute.md" 2>/dev/null || echo 0)

    if [ "$count" -ge 4 ]; then
        test_pass
    else
        test_fail "Expected 4+ Task: blocks, found $count"
    fi
}

test_sc2_dependency_analysis() {
    test_start "SC-2: 02_execute.md has dependency analysis step"

    if grep -q "Step 3.1" ".claude/commands/02_execute.md" 2>/dev/null && \
       grep -q "Dependency Analysis" ".claude/commands/02_execute.md" 2>/dev/null; then
        test_pass
    else
        test_fail "Dependency analysis step not found"
    fi
}

# ============================================================================
# SC-3: Add explicit parallel explorer + researcher to 00_plan.md
# ============================================================================
test_sc3_parallel_exploration() {
    test_start "SC-3: 00_plan.md has Step 1.1 Parallel Exploration"

    if grep -q "Step 1.1" ".claude/commands/00_plan.md" 2>/dev/null && \
       grep -q "Parallel Exploration" ".claude/commands/00_plan.md" 2>/dev/null; then
        test_pass
    else
        test_fail "Step 1.1 Parallel Exploration not found"
    fi
}

test_sc3_explorer_researcher_invocation() {
    test_start "SC-3: 00_plan.md has explorer + researcher subagent invocation"

    local count
    count=$(grep -A 30 "Step 1.1" ".claude/commands/00_plan.md" 2>/dev/null | grep -c "subagent_type:" || true)
    count=${count:-0}

    if [ "$count" -ge 2 ]; then
        test_pass
    else
        test_fail "Expected 2+ subagent_type: in Step 1.1, found $count"
    fi
}

# ============================================================================
# SC-4: Add 3-agent parallel verification to review.md
# ============================================================================
test_sc4_three_agent_parallel() {
    test_start "SC-4: review.md has 3+ subagent_type: invocations"

    local count
    count=$(grep -c "subagent_type:" ".claude/commands/review.md" 2>/dev/null || echo 0)

    if [ "$count" -ge 3 ]; then
        test_pass
    else
        test_fail "Expected 3+ subagent_type: invocations, found $count"
    fi
}

test_sc4_parallel_review_step() {
    test_start "SC-4: review.md has Multi-Angle Parallel Review step"

    if grep -q "Multi-Angle" ".claude/commands/review.md" 2>/dev/null && \
       grep -q "Parallel" ".claude/commands/review.md" 2>/dev/null; then
        test_pass
    else
        test_fail "Multi-Angle Parallel Review step not found"
    fi
}

# ============================================================================
# SC-5: Add parallel-subagents to Related Skills sections
# ============================================================================
test_sc5_related_skills() {
    test_start "SC-5: All relevant commands have parallel-subagents in Related Skills"

    local missing=""
    for cmd in 00_plan 02_execute review 03_close 05_cleanup; do
        # Extract Related Skills section
        if ! grep -A 5 "Related Skills" ".claude/commands/${cmd}.md" 2>/dev/null | grep -q "parallel-subagents"; then
            missing="${missing} ${cmd}"
        fi
    done

    if [ -n "$missing" ]; then
        test_fail "Commands missing parallel-subagents in Related Skills:${missing}"
    else
        test_pass
    fi
}

# ============================================================================
# Run all tests
# ============================================================================
main() {
    echo "================================"
    echo "Parallel Agents Integration Test Suite"
    echo "================================"
    echo ""

    test_sc1_commands_have_parallel_reference
    test_sc1_skill_has_command_patterns
    test_sc2_multi_coder_pattern
    test_sc2_dependency_analysis
    test_sc3_parallel_exploration
    test_sc3_explorer_researcher_invocation
    test_sc4_three_agent_parallel
    test_sc4_parallel_review_step
    test_sc5_related_skills

    # Print summary
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        echo ""
        return 1
    fi

    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    return 0
}

# Run main
main "$@"
