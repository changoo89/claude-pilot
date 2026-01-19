#!/bin/bash
# test_template_creation.test.sh
# Test CLAUDE.local.template.md template file structure

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
echo "Template Creation Test Suite"
echo "==================================="
echo ""

# Template file path
TEMPLATE_FILE=".claude/templates/CLAUDE.local.template.md"

# Test 1: Template file exists
echo "Test 1: Template file exists"
if [ -f "$TEMPLATE_FILE" ]; then
    test_result 0 "Template file exists at $TEMPLATE_FILE"
else
    test_result 1 "Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Test 2: Template has YAML frontmatter
echo ""
echo "Test 2: YAML frontmatter"
if grep -q "^---" "$TEMPLATE_FILE"; then
    # Count frontmatter delimiters (should have 2)
    FRONTMATTER_COUNT=$(grep -c "^---" "$TEMPLATE_FILE" || true)
    if [ "$FRONTMATTER_COUNT" -ge 2 ]; then
        test_result 0 "Template has YAML frontmatter delimiters"
    else
        test_result 1 "Template has incomplete frontmatter ($FRONTMATTER_COUNT/2 delimiters)"
    fi
else
    test_result 1 "Template missing YAML frontmatter"
fi

# Test 3: Template contains project configuration
echo ""
echo "Test 3: Project configuration section"
if grep -q "# Project Configuration" "$TEMPLATE_FILE"; then
    test_result 0 "Template contains Project Configuration section"
else
    test_result 1 "Template missing Project Configuration section"
fi

# Test 4: Template has required configuration keys
echo ""
echo "Test 4: Required configuration keys"
REQUIRED_KEYS=(
    "continuation_level"
    "coverage_threshold"
    "core_coverage_threshold"
    "max_iterations"
    "testing_framework"
    "type_check_command"
    "lint_command"
)

KEYS_FOUND=0
for key in "${REQUIRED_KEYS[@]}"; do
    if grep -q "$key" "$TEMPLATE_FILE"; then
        KEYS_FOUND=$((KEYS_FOUND + 1))
    fi
done

if [ $KEYS_FOUND -eq ${#REQUIRED_KEYS[@]} ]; then
    test_result 0 "All required config keys present (${KEYS_FOUND}/${#REQUIRED_KEYS[@]})"
else
    test_result 1 "Missing config keys (${KEYS_FOUND}/${#REQUIRED_KEYS[@]} present)"
fi

# Test 5: Template has project structure section
echo ""
echo "Test 5: Project structure section"
if grep -q "## Project Structure" "$TEMPLATE_FILE"; then
    test_result 0 "Template contains Project Structure section"
else
    test_result 1 "Template missing Project Structure section"
fi

# Test 6: Template has testing strategy section
echo ""
echo "Test 6: Testing strategy section"
if grep -q "## Testing Strategy" "$TEMPLATE_FILE"; then
    test_result 0 "Template contains Testing Strategy section"
else
    test_result 1 "Template missing Testing Strategy section"
fi

# Test 7: Template has quality standards section
echo ""
echo "Test 7: Quality standards section"
if grep -q "## Quality Standards" "$TEMPLATE_FILE"; then
    test_result 0 "Template contains Quality Standards section"
else
    test_result 1 "Template missing Quality Standards section"
fi

# Test 8: Template has use case examples
echo ""
echo "Test 8: Use case examples"
if grep -q "## Common Use Cases" "$TEMPLATE_FILE" || grep -q "## Use Cases" "$TEMPLATE_FILE"; then
    test_result 0 "Template contains use case examples section"
else
    echo -e "${YELLOW}WARNING${NC}: Template missing use case examples (not required but recommended)"
    test_result 0 "Use case examples check (warning only)"
fi

# Test 9: Template has placeholder values
echo ""
echo "Test 9: Placeholder values"
PLACEHOLDER_COUNT=0

# Check for common placeholder patterns
if grep -q "{Your Project Name}" "$TEMPLATE_FILE"; then
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
fi
if grep -q "{YYYY-MM-DD}" "$TEMPLATE_FILE"; then
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
fi
if grep -q "{pytest|jest}" "$TEMPLATE_FILE"; then
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
fi

if [ $PLACEHOLDER_COUNT -ge 2 ]; then
    test_result 0 "Template contains placeholder values (${PLACEHOLDER_COUNT}+ placeholders)"
else
    echo -e "${YELLOW}WARNING${NC}: Template has few placeholders (${PLACEHOLDER_COUNT} found)"
    test_result 0 "Placeholder check (warning only)"
fi

# Test 10: Template file size is reasonable
echo ""
echo "Test 10: Template file size"
TEMPLATE_SIZE=$(wc -c < "$TEMPLATE_FILE" | tr -d ' ')
# Template should be between 1KB and 100KB
if [ $TEMPLATE_SIZE -ge 1024 ] && [ $TEMPLATE_SIZE -le 102400 ]; then
    SIZE_KB=$((TEMPLATE_SIZE / 1024))
    test_result 0 "Template file size is reasonable (${SIZE_KB}KB)"
else
    echo -e "${YELLOW}WARNING${NC}: Template file size unusual (${TEMPLATE_SIZE} bytes)"
    test_result 0 "File size check (warning only)"
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
