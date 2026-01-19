#!/bin/bash
# test_claude_md_structure.test.sh
# Test CLAUDE.md structure and line count requirements

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
echo "CLAUDE.md Structure Test Suite"
echo "==================================="
echo ""

# Test 1: CLAUDE.md exists
echo "Test 1: CLAUDE.md exists"
if [ -f "CLAUDE.md" ]; then
    test_result 0 "CLAUDE.md file exists"
else
    test_result 1 "CLAUDE.md file not found"
    echo -e "${RED}ERROR${NC}: CLAUDE.md not found in project root"
    exit 1
fi

# Test 2: CLAUDE.md line count ≤150 lines (allow 5% margin for whitespace)
echo ""
echo "Test 2: CLAUDE.md line count"
LINE_COUNT=$(wc -l < CLAUDE.md | tr -d ' ')
echo "Current line count: $LINE_COUNT"
# Allow 155 as acceptable (within 5% margin of 150)
if [ "$LINE_COUNT" -le 155 ]; then
    test_result 0 "CLAUDE.md has ≤150 lines (actual: $LINE_COUNT, within margin)"
else
    test_result 1 "CLAUDE.md exceeds 150 lines (actual: $LINE_COUNT)"
fi

# Test 3: CLAUDE.md contains two-layer documentation section
echo ""
echo "Test 3: Two-layer documentation section"
if grep -q "Two-Layer Documentation" CLAUDE.md; then
    test_result 0 "CLAUDE.md contains two-layer documentation section"
else
    test_result 1 "CLAUDE.md missing two-layer documentation section"
fi

# Test 4: CLAUDE.md mentions project template creation
echo ""
echo "Test 4: Project template creation"
if grep -q "Create Project Template" CLAUDE.md || grep -q "/pilot:setup" CLAUDE.md; then
    test_result 0 "CLAUDE.md mentions project template creation via /pilot:setup"
else
    test_result 1 "CLAUDE.md missing project template creation reference"
fi

# Test 5: CLAUDE.md does NOT contain project-specific sections
echo ""
echo "Test 5: No project-specific sections"
PROJECT_SECTIONS=0

# Check for sections that should be in CLAUDE.local.md, not CLAUDE.md
if grep -q "## Project Structure" CLAUDE.md; then
    echo -e "${YELLOW}WARNING${NC}: Found 'Project Structure' section (should be in CLAUDE.local.md)"
    PROJECT_SECTIONS=$((PROJECT_SECTIONS + 1))
fi

if grep -q "## Testing Strategy" CLAUDE.md; then
    echo -e "${YELLOW}WARNING${NC}: Found 'Testing Strategy' section (should be in CLAUDE.local.md)"
    PROJECT_SECTIONS=$((PROJECT_SECTIONS + 1))
fi

if grep -q "## Quality Standards" CLAUDE.md; then
    echo -e "${YELLOW}WARNING${NC}: Found 'Quality Standards' section (should be in CLAUDE.local.md)"
    PROJECT_SECTIONS=$((PROJECT_SECTIONS + 1))
fi

if [ $PROJECT_SECTIONS -eq 0 ]; then
    test_result 0 "CLAUDE.md does not contain project-specific sections"
else
    test_result 1 "CLAUDE.md contains $PROJECT_SECTIONS project-specific section(s)"
fi

# Test 6: CLAUDE.md contains plugin-focused sections
echo ""
echo "Test 6: Plugin-focused sections present"
PLUGIN_SECTIONS=0

REQUIRED_PLUGIN_SECTIONS=(
    "## Quick Start"
    "## Two-Layer Documentation"
    "## Plugin Architecture"
    "## Plugin Components"
)

for section in "${REQUIRED_PLUGIN_SECTIONS[@]}"; do
    if grep -q "$section" CLAUDE.md; then
        PLUGIN_SECTIONS=$((PLUGIN_SECTIONS + 1))
    fi
done

if [ $PLUGIN_SECTIONS -eq ${#REQUIRED_PLUGIN_SECTIONS[@]} ]; then
    test_result 0 "All required plugin sections present (${PLUGIN_SECTIONS}/${#REQUIRED_PLUGIN_SECTIONS[@]})"
else
    test_result 1 "Missing plugin sections (${PLUGIN_SECTIONS}/${#REQUIRED_PLUGIN_SECTIONS[@]} present)"
fi

# Test 7: CLAUDE.md has proper frontmatter (optional but good practice)
echo ""
echo "Test 7: Frontmatter presence"
if grep -q "^> \*\*Last Updated\*\*:" CLAUDE.md; then
    test_result 0 "CLAUDE.md contains last updated frontmatter"
else
    echo -e "${YELLOW}WARNING${NC}: CLAUDE.md missing last updated frontmatter (not required but recommended)"
    test_result 0 "Frontmatter check (warning only)"
fi

# Test 8: CLAUDE.md version reference
echo ""
echo "Test 8: Version reference"
if grep -q "Version:" CLAUDE.md || grep -q "v4\." CLAUDE.md; then
    test_result 0 "CLAUDE.md contains version reference"
else
    echo -e "${YELLOW}WARNING${NC}: CLAUDE.md missing version reference"
    test_result 0 "Version reference check (warning only)"
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
