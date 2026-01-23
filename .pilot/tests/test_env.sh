#!/usr/bin/env bash
# Test suite for lib/env.sh
# Tests path resolution for PLUGIN_ROOT and PROJECT_DIR

# Don't use 'set -e' in tests - we want to run all tests
set -uo pipefail

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test assertions
assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_not_empty() {
    local value="$1"
    local message="${2:-Value should not be empty}"

    if [[ -n "$value" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

# Test setup
setup_test_env() {
    # Source the env.sh library
    if [[ -f "../lib/env.sh" ]]; then
        source "../lib/env.sh"
    elif [[ -f "lib/env.sh" ]]; then
        source "lib/env.sh"
    else
        echo "Error: Cannot find lib/env.sh"
        exit 1
    fi
}

# Test: PLUGIN_ROOT is exported
test_plugin_root_exported() {
    assert_not_empty "$PLUGIN_ROOT" "PLUGIN_ROOT should be exported and non-empty"
}

# Test: PLUGIN_ROOT points to a valid directory
test_plugin_root_exists() {
    assert_dir_exists "$PLUGIN_ROOT" "PLUGIN_ROOT directory should exist"
}

# Test: PLUGIN_ROOT contains lib directory
test_plugin_root_has_lib() {
    assert_dir_exists "$LIB_DIR" "LIB_DIR should exist at \$PLUGIN_ROOT/lib"
}

# Test: PROJECT_DIR is exported
test_project_dir_exported() {
    assert_not_empty "$PROJECT_DIR" "PROJECT_DIR should be exported and non-empty"
}

# Test: PROJECT_DIR points to a valid directory
test_project_dir_exists() {
    assert_dir_exists "$PROJECT_DIR" "PROJECT_DIR directory should exist"
}

# Test: PROJECT_DIR contains .claude directory
test_project_dir_has_claude() {
    assert_dir_exists "$CONFIG_DIR" "CONFIG_DIR should exist at \$PROJECT_DIR/.claude"
}

# Test: PROJECT_DIR contains .pilot directory
test_project_dir_has_pilot() {
    assert_dir_exists "$PILOT_DIR" "PILOT_DIR should exist at \$PROJECT_DIR/.pilot"
}

# Test: CACHE_DIR is exported
test_cache_dir_exported() {
    assert_not_empty "$CACHE_DIR" "CACHE_DIR should be exported and non-empty"
}

# Test: All path variables are absolute paths
test_paths_are_absolute() {
    local message

    # Check PLUGIN_ROOT
    if [[ "$PLUGIN_ROOT" == /* ]]; then
        echo -e "${GREEN}✓${NC} PLUGIN_ROOT is an absolute path"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} PLUGIN_ROOT is not an absolute path: $PLUGIN_ROOT"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))

    # Check PROJECT_DIR
    if [[ "$PROJECT_DIR" == /* ]]; then
        echo -e "${GREEN}✓${NC} PROJECT_DIR is an absolute path"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} PROJECT_DIR is not an absolute path: $PROJECT_DIR"
        ((TESTS_FAILED++))
    fi
    ((TESTS_RUN++))
}

# Main test runner
main() {
    echo "Running lib/env.sh tests..."
    echo ""

    # Setup
    setup_test_env

    # Run tests
    test_plugin_root_exported
    test_plugin_root_exists
    test_plugin_root_has_lib
    test_project_dir_exported
    test_project_dir_exists
    test_project_dir_has_claude
    test_project_dir_has_pilot
    test_cache_dir_exported
    test_paths_are_absolute

    # Summary
    echo ""
    echo "Test Results:"
    echo "  Run: $TESTS_RUN"
    echo -e "  ${GREEN}Passed${NC}: $TESTS_PASSED"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed${NC}: $TESTS_FAILED"
    fi

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

# Run tests
main "$@"
