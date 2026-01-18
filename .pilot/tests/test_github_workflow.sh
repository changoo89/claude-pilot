#!/usr/bin/env bash
#
# test_github_workflow.sh - Integration test for GitHub Actions release workflow
#
# Tests SC-1: GitHub Actions workflow created and triggered on tag push

set -euo pipefail

# Source test helpers if available
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

if [ -f "$TEST_DIR/test_helpers.sh" ]; then
    source "$TEST_DIR/test_helpers.sh"
fi

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result functions
test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  PASS: $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $1"
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo "Test $TESTS_RUN: $1"
}

# Change to project root
cd "$PROJECT_ROOT"

echo "======================================"
echo "GitHub Workflow Integration Test"
echo "======================================"
echo ""

# Test 1: Workflow file exists
run_test "Workflow file exists"
if [ -f ".github/workflows/release.yml" ]; then
    test_pass "release.yml exists at .github/workflows/release.yml"
else
    test_fail "release.yml not found"
fi

# Test 2: Workflow has correct trigger
run_test "Workflow triggers on tag push (v*)"
if grep -q "tags:" .github/workflows/release.yml && \
   grep -q "v\*" .github/workflows/release.yml; then
    test_pass "Workflow triggers on v* tag pattern"
else
    test_fail "Workflow missing v* tag trigger"
fi

# Test 3: Workflow has correct permissions
run_test "Workflow has contents:write permission"
if grep -q "permissions:" .github/workflows/release.yml && \
   grep -q "contents: write" .github/workflows/release.yml; then
    test_pass "Workflow has contents:write permission"
else
    test_fail "Workflow missing contents:write permission"
fi

# Test 4: Workflow uses correct actions
run_test "Workflow uses actions/checkout@v4"
if grep -q "actions/checkout@v4" .github/workflows/release.yml; then
    test_pass "Workflow uses actions/checkout@v4"
else
    test_fail "Workflow not using actions/checkout@v4"
fi

run_test "Workflow uses softprops/action-gh-release@v1"
if grep -q "softprops/action-gh-release@v1" .github/workflows/release.yml; then
    test_pass "Workflow uses softprops/action-gh-release@v1"
else
    test_fail "Workflow not using softprops/action-gh-release@v1"
fi

# Test 5: Workflow validates version consistency
run_test "Workflow validates version consistency"
if grep -q "Validate version consistency" .github/workflows/release.yml && \
   grep -q "validate_versions.sh" .github/workflows/release.yml; then
    test_pass "Workflow uses validation script"
else
    test_fail "Workflow missing version validation"
fi

# Test 6: Workflow extracts CHANGELOG
run_test "Workflow extracts CHANGELOG for release notes"
if grep -q "Extract release notes from CHANGELOG" .github/workflows/release.yml && \
   grep -q "CHANGELOG.md" .github/workflows/release.yml; then
    test_pass "Workflow extracts CHANGELOG content"
else
    test_fail "Workflow missing CHANGELOG extraction"
fi

# Test 7: Validation script exists and is executable
run_test "Validation script exists and is executable"
if [ -x ".github/scripts/validate_versions.sh" ]; then
    test_pass "validate_versions.sh exists and is executable"
else
    test_fail "validate_versions.sh not found or not executable"
fi

# Test 8: Validation script works with matching versions
run_test "Validation script accepts matching versions"
if .github/scripts/validate_versions.sh "4.1.7" >/dev/null 2>&1; then
    test_pass "Validation passes for matching versions"
else
    test_fail "Validation failed for matching versions"
fi

# Test 9: Validation script rejects mismatched versions
run_test "Validation script rejects mismatched versions"
if ! .github/scripts/validate_versions.sh "9.9.9" >/dev/null 2>&1; then
    test_pass "Validation correctly rejects mismatched versions"
else
    test_fail "Validation did not reject mismatched versions"
fi

# Test 10: Workflow YAML syntax is valid
run_test "Workflow YAML syntax is valid"
if command -v yamllint &> /dev/null; then
    if yamllint .github/workflows/release.yml >/dev/null 2>&1; then
        test_pass "Workflow YAML syntax is valid (yamllint)"
    else
        test_fail "Workflow YAML has syntax errors"
    fi
else
    # Fallback: basic syntax check with python
    if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/release.yml'))" 2>/dev/null; then
        test_pass "Workflow YAML syntax is valid (python)"
    else
        echo "  SKIP: No YAML validator available"
    fi
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
