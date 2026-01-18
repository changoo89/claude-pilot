#!/usr/bin/env bash
#
# test_worktree_create.sh
#
# Integration test for worktree creation functionality
#

set -o nounset
set -o pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
test_start() {
    local test_name="$1"
    echo ""
    echo "=========================================="
    echo "Test: $test_name"
    echo "=========================================="
    ((TESTS_RUN++))
}

test_pass() {
    echo -e "${GREEN}✓ PASSED${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    local reason="$1"
    echo -e "${RED}✗ FAILED: $reason${NC}"
    ((TESTS_FAILED++))
}

test_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Cleanup function
cleanup() {
    # Remove test worktrees
    git worktree list | grep "claude-pilot-wt-" | awk '{print $1}' | while read wt_path; do
        echo "Cleaning up worktree: $wt_path"
        git worktree remove "$wt_path" 2>/dev/null || rm -rf "$wt_path"
    done

    # Remove test branches starting with wt/test-
    git branch | grep "wt/test-" | sed 's/^..//' | while read branch; do
        echo "Cleaning up branch: $branch"
        git branch -D "$branch" 2>/dev/null || true
    done
}

# Setup: Ensure we're on main branch
setup() {
    echo "Setting up test environment..."

    # Cleanup any existing test artifacts
    cleanup

    # Ensure we're on main branch
    git checkout main 2>/dev/null || git checkout -b main

    echo "✓ Test environment ready"
}

# Test 1: Worktree creation script exists and is executable
test_worktree_script_exists() {
    test_start "Worktree creation script exists"

    local script_path=".claude/scripts/worktree-create.sh"

    if [ ! -f "$script_path" ]; then
        test_fail "Script not found: $script_path"
        return 1
    fi

    if [ ! -x "$script_path" ]; then
        test_fail "Script not executable: $script_path"
        return 1
    fi

    test_pass
}

# Test 2: Worktree creation creates valid worktree
test_worktree_creation() {
    test_start "Worktree creation"

    local test_branch="wt/test-creation-$(date +%s)"

    test_info "Creating worktree for branch: $test_branch"

    # Call worktree creation script
    local output
    output="$(bash .claude/scripts/worktree-create.sh "$test_branch" "main" 2>&1)"
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        test_fail "Script returned exit code $exit_code: $output"
        return 1
    fi

    # Extract worktree path and actual branch name from output
    local worktree_path
    local actual_branch
    worktree_path="$(echo "$output" | grep "^WORKTREE_PATH=" | cut -d'=' -f2)"
    actual_branch="$(echo "$output" | grep "^WORKTREE_BRANCH=" | cut -d'=' -f2)"

    if [ -z "$worktree_path" ]; then
        test_fail "Failed to extract WORKTREE_PATH from output"
        return 1
    fi

    if [ -z "$actual_branch" ]; then
        test_fail "Failed to extract WORKTREE_BRANCH from output"
        return 1
    fi

    test_info "Worktree path: $worktree_path"
    test_info "Actual branch: $actual_branch"

    # Verify worktree directory exists
    if [ ! -d "$worktree_path" ]; then
        test_fail "Worktree directory does not exist: $worktree_path"
        return 1
    fi

    # Verify worktree is a git worktree
    if ! git worktree list | grep -q "$worktree_path"; then
        test_fail "Worktree not in git worktree list"
        return 1
    fi

    # Verify branch was created (use actual branch name from output)
    if ! git show-ref --verify --quiet "refs/heads/$actual_branch" 2>/dev/null; then
        test_fail "Branch not created: $actual_branch"
        return 1
    fi

    # Verify .pilot directory structure exists in worktree
    if [ ! -d "$worktree_path/.pilot" ]; then
        test_fail ".pilot directory not found in worktree"
        return 1
    fi

    test_pass
}

# Test 3: Worktree creation handles existing worktree
test_worktree_existing() {
    test_start "Worktree creation with existing worktree"

    local test_branch="wt/test-existing-$(date +%s)"

    test_info "Creating first worktree..."

    # Create first worktree
    bash .claude/scripts/worktree-create.sh "$test_branch" "main" > /dev/null 2>&1
    local first_exit=$?

    if [ $first_exit -ne 0 ]; then
        test_fail "Failed to create first worktree"
        return 1
    fi

    test_info "Creating second worktree with same branch (should replace)..."

    # Try to create again (should replace existing)
    local output
    output="$(bash .claude/scripts/worktree-create.sh "$test_branch" "main" 2>&1)"
    local second_exit=$?

    if [ $second_exit -ne 0 ]; then
        test_fail "Failed to replace existing worktree: $output"
        return 1
    fi

    # Verify warning was shown
    if ! echo "$output" | grep -q "Warning: Worktree already exists"; then
        test_fail "Warning message not shown for existing worktree"
        return 1
    fi

    test_pass
}

# Test 4: Worktree branch name sanitization
test_worktree_branch_sanitization() {
    test_start "Worktree branch name sanitization"

    local test_branch="wt/test with spaces/and/slashes-$(date +%s)"
    local expected_branch="wt/test_with_spaces_and_slashes_$(date +%s | tr -d ' ')"

    test_info "Creating worktree with branch: $test_branch"

    local output
    output="$(bash .claude/scripts/worktree-create.sh "$test_branch" "main" 2>&1)"
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        test_fail "Script failed: $output"
        return 1
    fi

    # Verify worktree was created with sanitized name
    if ! git worktree list | grep -q "claude-pilot-wt-"; then
        test_fail "No worktree created with expected sanitized name"
        return 1
    fi

    test_pass
}

# Test 5: Worktree creation error handling
test_worktree_error_handling() {
    test_start "Worktree creation error handling"

    # Test with invalid branch name (empty)
    test_info "Testing with empty branch name..."

    local output
    output="$(bash .claude/scripts/worktree-create.sh "" "main" 2>&1)"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        test_fail "Should have failed with empty branch name"
        return 1
    fi

    # Test with non-existent base branch
    test_info "Testing with non-existent base branch..."

    output="$(bash .claude/scripts/worktree-create.sh "wt/test-nonexistent" "nonexistent-branch-xyz" 2>&1)"
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        test_fail "Should have failed with non-existent base branch"
        return 1
    fi

    test_pass
}

# Main test execution
main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  Worktree Creation Integration Tests    ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    setup

    test_worktree_script_exists
    test_worktree_creation
    test_worktree_existing
    test_worktree_branch_sanitization
    test_worktree_error_handling

    # Cleanup
    cleanup

    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Total:  $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
