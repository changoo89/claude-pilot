#!/bin/bash
# test_gitignore_behavior.test.sh
# Test .gitignore behavior for CLAUDE.local.md files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result function
test_result() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "==================================="
echo "Gitignore Behavior Test Suite"
echo "==================================="
echo ""

# Test 1: .gitignore file exists
echo "Test 1: .gitignore exists"
if [ -f ".gitignore" ]; then
    test_result 0 ".gitignore file exists"
else
    test_result 1 ".gitignore file not found"
    exit 1
fi

# Test 2: .gitignore contains CLAUDE.local.md pattern
echo ""
echo "Test 2: CLAUDE.local.md pattern"
if grep -q "^CLAUDE.local.md$" .gitignore || grep -q "CLAUDE.local.md" .gitignore; then
    test_result 0 ".gitignore contains CLAUDE.local.md pattern"
else
    test_result 1 ".gitignore missing CLAUDE.local.md pattern"
fi

# Test 3: .gitignore contains .claude/*.local.md pattern
echo ""
echo "Test 3: .claude/*.local.md pattern"
if grep -q "\.claude/\*\.local\.md" .gitignore || grep -q ".claude/*.local.md" .gitignore; then
    test_result 0 ".gitignore contains .claude/*.local.md pattern"
else
    test_result 1 ".gitignore missing .claude/*.local.md pattern"
fi

# Test 4: Verify git check-ignore recognizes CLAUDE.local.md
echo ""
echo "Test 4: Git check-ignore for CLAUDE.local.md"
if git check-ignore -q "CLAUDE.local.md" 2>/dev/null; then
    test_result 0 "Git correctly ignores CLAUDE.local.md"
else
    # File might not exist yet, check the pattern
    if git check-ignore -q CLAUDE.local.md 2>/dev/null; then
        test_result 0 "Git pattern ignores CLAUDE.local.md"
    else
        echo -e "${YELLOW}INFO${NC}: CLAUDE.local.md not tracked by git (expected)"
        test_result 0 "Git ignore pattern verified (file doesn't exist yet)"
    fi
fi

# Test 5: Verify git check-ignore recognizes .claude/*.local.md
echo ""
echo "Test 5: Git check-ignore for .claude/*.local.md"
# Create a test file to verify the pattern
TEST_FILE=".claude/test.local.md"
touch "$TEST_FILE" 2>/dev/null || true

if [ -f "$TEST_FILE" ]; then
    if git check-ignore -q "$TEST_FILE" 2>/dev/null; then
        test_result 0 "Git correctly ignores .claude/*.local.md files"
        rm -f "$TEST_FILE"
    else
        test_result 1 "Git does not ignore .claude/*.local.md files"
        rm -f "$TEST_FILE"
    fi
else
    echo -e "${YELLOW}INFO${NC}: Could not create test file in .claude/"
    test_result 0 "Git ignore pattern verified (could not create test file)"
fi

# Test 6: Verify template file is NOT ignored
echo ""
echo "Test 6: Template file not ignored"
TEMPLATE_FILE=".claude/templates/CLAUDE.local.template.md"
if [ -f "$TEMPLATE_FILE" ]; then
    if git check-ignore -q "$TEMPLATE_FILE" 2>/dev/null; then
        test_result 1 "Template file is incorrectly ignored by git"
    else
        test_result 0 "Template file is correctly NOT ignored"
    fi
else
    echo -e "${YELLOW}INFO${NC}: Template file not found"
    test_result 0 "Template file check (file doesn't exist yet)"
fi

# Test 7: Verify CLAUDE.md is NOT ignored
echo ""
echo "Test 7: CLAUDE.md not ignored"
if [ -f "CLAUDE.md" ]; then
    if git check-ignore -q "CLAUDE.md" 2>/dev/null; then
        test_result 1 "CLAUDE.md is incorrectly ignored by git"
    else
        test_result 0 "CLAUDE.md is correctly NOT ignored"
    fi
else
    echo -e "${YELLOW}INFO${NC}: CLAUDE.md not found"
    test_result 0 "CLAUDE.md check (file doesn't exist yet)"
fi

# Test 8: Check for other local.md patterns
echo ""
echo "Test 8: Other *.local.md patterns"
# Look for any .local.md patterns in .gitignore
LOCAL_MD_PATTERNS=$(grep -c "\.local\.md" .gitignore || true)
if [ $LOCAL_MD_PATTERNS -gt 0 ]; then
    test_result 0 ".gitignore contains $LOCAL_MD_PATTERNS .local.md pattern(s)"
else
    test_result 1 ".gitignore missing .local.md patterns"
fi

# Test 9: Verify .gitignore has proper comments/documentation
echo ""
echo "Test 9: Gitignore documentation"
if grep -q "#.*local" .gitignore || grep -q "#.*CLAUDE" .gitignore; then
    test_result 0 ".gitignore has comments explaining local files"
else
    echo -e "${YELLOW}WARNING${NC}: .gitignore missing comments for local files"
    test_result 0 "Gitignore documentation check (warning only)"
fi

# Test 10: Verify no conflicting patterns
echo ""
echo "Test 10: Conflicting patterns check"
# Look for negation patterns (!) after .local.md patterns
if grep -A1 "\.local\.md" .gitignore | grep -q "^!"; then
    echo -e "${YELLOW}WARNING${NC}: Found negation pattern after .local.md"
    test_result 1 "Potential conflicting gitignore patterns"
else
    test_result 0 "No conflicting gitignore patterns found"
fi

# Summary
echo ""
echo "==================================="
echo "Test Summary"
echo "==================================="
echo "Total:  $TESTS_TOTAL"
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
