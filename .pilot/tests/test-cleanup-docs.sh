#!/usr/bin/env bash
# Test suite for /05_cleanup documentation cleanup exclusions
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
NC='\033[0m' # No Color

# Helper functions
test_start() {
    local test_name="$1"
    echo "🧪 Test: $test_name"
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

# Setup and teardown
setup() {
    # Create test fixtures directory
    rm -rf /tmp/cleanup_test
    mkdir -p /tmp/cleanup_test
    cd /tmp/cleanup_test
}

teardown() {
    # Remove test fixtures
    rm -rf /tmp/cleanup_test
}

# Trap to ensure teardown runs
trap teardown EXIT

# ============================================================================
# SC-1: Plugin .claude/ directory excluded from docs cleanup
# ============================================================================
test_sc1_plugin_excluded() {
    test_start "SC-1: Plugin .claude/ directory excluded"

    # Create a .claude file with no @references
    mkdir -p .claude/commands
    echo "# Test command with no references" > .claude/commands/test_command.md

    # Run the ripgrep command from 05_cleanup.md
    doc_files=$(rg --files --glob '*.md' --glob '!*.md.bak' \
        --glob '!docs/**' \
        --glob '!README.md' \
        --glob '!CLAUDE.md' \
        --glob '!**/.trash/**' \
        --glob '!.claude/agents/**' \
        --glob '!.claude/commands/**' \
        --glob '!.claude/guides/**' \
        --glob '!.claude/hooks/**' \
        --glob '!.claude/skills/**' \
        --glob '!.claude/templates/**' \
        --glob '!.claude/tests/**' \
        --glob '!.claude/**/CONTEXT.md' \
        --glob '!**/CONTEXT.md' \
        --glob '!.pilot/plan/**' \
        --hidden \
        . 2>/dev/null || true)

    # Check that .claude/ files are NOT in the output
    if echo "$doc_files" | grep -q '\.claude/(commands|agents|guides|hooks|skills|templates|tests)/'; then
        test_fail ".claude/ files should be excluded but found: $doc_files"
    else
        test_pass
    fi
}

# ============================================================================
# SC-2: CONTEXT.md files protected regardless of reference count
# ============================================================================
test_sc2_context_protected() {
    test_start "SC-2: CONTEXT.md files protected"

    # Create CONTEXT.md with no @references
    mkdir -p test_dir
    echo "# Test CONTEXT with no refs" > test_dir/CONTEXT.md

    # Run the ripgrep command
    doc_files=$(rg --files --glob '*.md' --glob '!*.md.bak' \
        --glob '!docs/**' \
        --glob '!README.md' \
        --glob '!CLAUDE.md' \
        --glob '!**/.trash/**' \
        --glob '!.claude/agents/**' \
        --glob '!.claude/commands/**' \
        --glob '!.claude/guides/**' \
        --glob '!.claude/hooks/**' \
        --glob '!.claude/skills/**' \
        --glob '!.claude/templates/**' \
        --glob '!.claude/tests/**' \
        --glob '!.claude/**/CONTEXT.md' \
        --glob '!**/CONTEXT.md' \
        --glob '!.pilot/plan/**' \
        --hidden \
        . 2>/dev/null || true)

    # Check that CONTEXT.md is NOT in candidates
    if echo "$doc_files" | grep -q 'CONTEXT.md'; then
        test_fail "CONTEXT.md should be excluded but found in: $doc_files"
    else
        test_pass
    fi
}

# ============================================================================
# SC-3: .pilot/plan/ state directories protected
# ============================================================================
test_sc3_pilot_protected() {
    test_start "SC-3: .pilot/plan/ state directories protected"

    # Create unreferenced plan files in state directories
    mkdir -p .pilot/plan/draft
    mkdir -p .pilot/plan/pending
    mkdir -p .pilot/plan/in_progress
    mkdir -p .pilot/plan/done

    echo "# Draft plan" > .pilot/plan/draft/test_plan.md
    echo "# Pending plan" > .pilot/plan/pending/test_plan.md
    echo "# In progress plan" > .pilot/plan/in_progress/test_plan.md
    echo "# Done plan" > .pilot/plan/done/test_plan.md

    # Run the ripgrep command
    doc_files=$(rg --files --glob '*.md' --glob '!*.md.bak' \
        --glob '!docs/**' \
        --glob '!README.md' \
        --glob '!CLAUDE.md' \
        --glob '!**/.trash/**' \
        --glob '!.claude/agents/**' \
        --glob '!.claude/commands/**' \
        --glob '!.claude/guides/**' \
        --glob '!.claude/hooks/**' \
        --glob '!.claude/skills/**' \
        --glob '!.claude/templates/**' \
        --glob '!.claude/tests/**' \
        --glob '!.claude/**/CONTEXT.md' \
        --glob '!**/CONTEXT.md' \
        --glob '!.pilot/plan/**' \
        --hidden \
        . 2>/dev/null || true)

    # Check that .pilot/plan/ files are NOT in candidates
    if echo "$doc_files" | grep -q '\.pilot/plan/'; then
        test_fail ".pilot/plan/ files should be excluded but found in: $doc_files"
    else
        test_pass
    fi
}

# ============================================================================
# SC-4: .claude/generated/ files still cleanup targets
# ============================================================================
test_sc4_generated_cleaned() {
    test_start "SC-4: .claude/generated/ files still cleanup targets"

    # Create unreferenced file in .claude/generated/
    mkdir -p .claude/generated
    echo "# Unreferenced generated file" > .claude/generated/test_unref.md

    # Run the ripgrep command with updated patterns
    doc_files=$(rg --files --glob '*.md' --glob '!*.md.bak' \
        --glob '!docs/**' \
        --glob '!README.md' \
        --glob '!CLAUDE.md' \
        --glob '!**/.trash/**' \
        --glob '!.claude/agents/**' \
        --glob '!.claude/commands/**' \
        --glob '!.claude/guides/**' \
        --glob '!.claude/hooks/**' \
        --glob '!.claude/skills/**' \
        --glob '!.claude/templates/**' \
        --glob '!.claude/tests/**' \
        --glob '!.claude/**/CONTEXT.md' \
        --glob '!**/CONTEXT.md' \
        --glob '!.pilot/plan/**' \
        --hidden \
        . 2>/dev/null || true)

    # Check that .claude/generated/ file IS in candidates
    if echo "$doc_files" | grep -q '\.claude/generated/test_unref\.md'; then
        test_pass
    else
        test_fail ".claude/generated/test_unref.md should be a cleanup candidate but was excluded. Found: $doc_files"
    fi
}

# ============================================================================
# SC-5: Backup and temp patterns still work
# ============================================================================
test_sc5_backup_excluded() {
    test_start "SC-5: Backup patterns still excluded"

    # Create backup file
    echo "# Test backup" > test.md.bak

    # Run the ripgrep command
    doc_files=$(rg --files --glob '*.md' --glob '!*.md.bak' \
        --glob '!docs/**' \
        --glob '!README.md' \
        --glob '!CLAUDE.md' \
        --glob '!**/.trash/**' \
        --glob '!.claude/agents/**' \
        --glob '!.claude/commands/**' \
        --glob '!.claude/guides/**' \
        --glob '!.claude/hooks/**' \
        --glob '!.claude/skills/**' \
        --glob '!.claude/templates/**' \
        --glob '!.claude/tests/**' \
        --glob '!.claude/**/CONTEXT.md' \
        --glob '!**/CONTEXT.md' \
        --glob '!.pilot/plan/**' \
        --hidden \
        . 2>/dev/null || true)

    # Check that backup file is NOT in candidates
    if echo "$doc_files" | grep -q 'test\.md\.bak'; then
        test_fail "test.md.bak should be excluded but found in: $doc_files"
    else
        test_pass
    fi
}

# ============================================================================
# Run all tests
# ============================================================================
main() {
    echo "================================"
    echo "Documentation Cleanup Exclusions Test Suite"
    echo "================================"
    echo ""

    setup

    test_sc1_plugin_excluded
    test_sc2_context_protected
    test_sc3_pilot_protected
    test_sc4_generated_cleaned
    test_sc5_backup_excluded

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
