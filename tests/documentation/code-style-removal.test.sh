#!/usr/bin/env bash
# Test: Code Style Removal Verification (TS-5)
# Purpose: Verify code style guidelines removed from CLAUDE.md and moved to appropriate docs

set -uo pipefail
# Note: 'set -e' removed to allow script to continue after test failures

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_pass() {
    local test_name="$1"
    echo -e "${GREEN}✓ PASS${NC}: $test_name"
    ((TESTS_PASSED++))
}

assert_fail() {
    local test_name="$1"
    local reason="$2"
    echo -e "${RED}✗ FAIL${NC}: $test_name"
    echo -e "  ${YELLOW}Reason:${NC} $reason"
    ((TESTS_FAILED++))
}

# Test 1: Verify CLAUDE.md exists
test_claude_md_exists() {
    if [ -f "/Users/chanho/claude-pilot/CLAUDE.md" ]; then
        assert_pass "CLAUDE.md exists"
    else
        assert_fail "CLAUDE.md exists" "File not found"
        return 1
    fi
}

# Test 2: Verify no dedicated code style section in CLAUDE.md
test_no_code_style_section() {
    local claude_md="/Users/chanho/claude-pilot/CLAUDE.md"

    # Check for dedicated code style sections (anti-pattern)
    if grep -qi "^## Code Style" "$claude_md"; then
        assert_fail "No dedicated 'Code Style' section" "Found '## Code Style' section header"
        return 1
    fi

    if grep -qi "^## Coding Style" "$claude_md"; then
        assert_fail "No dedicated 'Coding Style' section" "Found '## Coding Style' section header"
        return 1
    fi

    if grep -qi "^## Style Guide" "$claude_md"; then
        assert_fail "No dedicated 'Style Guide' section" "Found '## Style Guide' section header"
        return 1
    fi

    assert_pass "No dedicated code style section in CLAUDE.md"
}

# Test 3: Verify code style references point to external docs
test_code_style_references() {
    local claude_md="/Users/chanho/claude-pilot/CLAUDE.md"

    # Should reference testing-quality.md for quality standards
    if grep -q "testing-quality.md" "$claude_md"; then
        assert_pass "CLAUDE.md references testing-quality.md"
    else
        assert_fail "CLAUDE.md references testing-quality.md" "No reference to testing-quality.md found"
        return 1
    fi
}

# Test 4: Verify testing-quality.md exists and contains quality info
test_testing_quality_doc_exists() {
    local quality_doc="/Users/chanho/claude-pilot/docs/ai-context/testing-quality.md"

    if [ ! -f "$quality_doc" ]; then
        assert_fail "testing-quality.md exists" "File not found at $quality_doc"
        return 1
    fi

    # Verify it contains quality standards
    if grep -qi "Coverage Targets" "$quality_doc"; then
        assert_pass "testing-quality.md contains coverage targets"
    else
        assert_fail "testing-quality.md contains coverage targets" "Coverage Targets section not found"
        return 1
    fi

    # Verify it mentions lint/type-check
    if grep -qi "lint" "$quality_doc"; then
        assert_pass "testing-quality.md mentions lint"
    else
        assert_fail "testing-quality.md mentions lint" "Lint reference not found"
        return 1
    fi
}

# Test 5: Verify minimal style/format mentions in CLAUDE.md (only in context)
test_minimal_style_mentions() {
    local claude_md="/Users/chanho/claude-pilot/CLAUDE.md"

    # Count mentions of style/format/lint (excluding Testing & Quality section)
    local style_count
    style_count=$(grep -i "style\|format" "$claude_md" | wc -l | tr -d ' ')

    # Should be minimal (< 10 mentions)
    if [ "$style_count" -lt 10 ]; then
        assert_pass "Minimal style/format mentions in CLAUDE.md ($style_count mentions)"
    else
        assert_fail "Minimal style/format mentions in CLAUDE.md" "Too many mentions ($style_count), suggests dedicated section"
        return 1
    fi
}

# Test 6: Verify quality gates properly reference external docs
test_quality_gates_reference() {
    local claude_md="/Users/chanho/claude-pilot/CLAUDE.md"

    # Should have Testing & Quality section that references external doc
    if grep -A10 "^## Testing & Quality" "$claude_md" | grep -q "testing-quality.md"; then
        assert_pass "Testing & Quality section references testing-quality.md"
    else
        # Check if at least references external docs somewhere
        if grep -q "docs/ai-context/testing-quality" "$claude_md"; then
            assert_pass "CLAUDE.md references testing-quality in Related Documentation"
        else
            assert_fail "Testing & Quality section references external docs" "No reference to testing-quality.md found"
            return 1
        fi
    fi
}

# Run all tests
echo "=========================================="
echo "Test: Code Style Removal Verification (TS-5)"
echo "=========================================="
echo ""

test_claude_md_exists
test_no_code_style_section
test_code_style_references
test_testing_quality_doc_exists
test_minimal_style_mentions
test_quality_gates_reference

echo ""
echo "=========================================="
echo "Test Results Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
