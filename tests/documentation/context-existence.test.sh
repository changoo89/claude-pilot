#!/usr/bin/env bash
# Test: CONTEXT.md existence check for TS-2
# Description: Verify all major .claude directories have CONTEXT.md files

set -euo pipefail

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_file_exists() {
    local file_path="$1"
    local test_name="CONTEXT.md exists: $file_path"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Main test execution
main() {
    echo "======================================"
    echo "Test Suite: CONTEXT.md Existence Check"
    echo "======================================"
    echo ""

    local base_dir="/Users/chanho/claude-pilot/.claude"

    # Test all required CONTEXT.md files
    test_file_exists "$base_dir/commands/CONTEXT.md"
    test_file_exists "$base_dir/guides/CONTEXT.md"
    test_file_exists "$base_dir/agents/CONTEXT.md"
    test_file_exists "$base_dir/skills/CONTEXT.md"
    test_file_exists "$base_dir/rules/CONTEXT.md"
    test_file_exists "$base_dir/scripts/CONTEXT.md"

    echo ""
    echo "======================================"
    echo "Test Results Summary"
    echo "======================================"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        return 1
    fi
}

# Run tests
main
