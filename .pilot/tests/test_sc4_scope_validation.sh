#!/usr/bin/env bash
#
# Test SC-4: Scope Validation for /04_fix Command
#
# This test verifies that the /04_fix command properly validates task scope
# and rejects complex tasks that should use /00_plan instead.
#
# Test Strategy:
# - Simulate scope validation algorithm
# - Test various complexity scenarios
# - Verify rejection with appropriate error messages
#

set -euo pipefail

# Test framework helpers
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Scope validation algorithm (from plan SC-2)
# Returns complexity score (0.0-1.0)
calculate_complexity_score() {
    local input="$1"
    local score=0.0

    # Check 1: Input length (>200 chars → +0.5, long inputs indicate complex tasks)
    local length=${#input}
    if [ $length -gt 200 ]; then
        score=$(echo "$score + 0.5" | bc)
    fi

    # Check 2: Keyword detection ("refactor", "architecture", "tradeoffs" → +0.5 for instant rejection)
    # These keywords alone indicate complexity beyond simple bug fixes
    local keywords="refactor|redesign|architecture|tradeoff|design"
    if echo "$input" | grep -qiE "$keywords"; then
        score=$(echo "$score + 0.5" | bc)
    fi

    # Check 2b: System keyword (less severe → +0.3)
    if echo "$input" | grep -qiE "\bsystem\b"; then
        score=$(echo "$score + 0.3" | bc)
    fi

    # Check 3: File count (>3 files mentioned → +0.3, indicates multi-file coordination)
    # Count file-like patterns (e.g., "file.ts", "path/to/file")
    local file_count=$(echo "$input" | grep -oE '\b[a-zA-Z0-9_/-]+\.[a-zA-Z]{2,4}\b' | wc -l | tr -d ' ')
    if [ "$file_count" -gt 3 ]; then
        score=$(echo "$score + 0.3" | bc)
    fi

    # Check 4: Multiple tasks (AND, THEN, ALSO connectors)
    # Count occurrences - multiple connectors indicate multiple distinct tasks
    local connector_count=$(echo "$input" | grep -oiE '\b(AND|THEN|ALSO)\b' | wc -l | tr -d ' ')
    if [ "$connector_count" -ge 2 ]; then
        # 2+ connectors → +0.5 (clearly multiple tasks)
        score=$(echo "$score + 0.5" | bc)
    elif [ "$connector_count" -eq 1 ]; then
        # 1 connector → +0.2 (might be related tasks)
        score=$(echo "$score + 0.2" | bc)
    fi

    # Return score rounded to 1 decimal
    printf "%.1f" "$score"
}

# Test helper: Verify rejection
assert_rejected() {
    local input="$1"
    local expected_reason="$2"
    local score
    score=$(calculate_complexity_score "$input")

    TESTS_RUN=$((TESTS_RUN + 1))

    # Check if score meets rejection threshold (≥0.5)
    local rejected=$(echo "$score >= 0.5" | bc)

    if [ "$rejected" -eq 1 ]; then
        log_success "Test $TESTS_RUN: Input rejected (score: $score)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "Test $TESTS_RUN: Expected rejection but got score $score (threshold: 0.5)"
        log_error "  Input: $input"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test helper: Verify acceptance
assert_accepted() {
    local input="$1"
    local score
    score=$(calculate_complexity_score "$input")

    TESTS_RUN=$((TESTS_RUN + 1))

    # Check if score is below rejection threshold (<0.5)
    local accepted=$(echo "$score < 0.5" | bc)

    if [ "$accepted" -eq 1 ]; then
        log_success "Test $TESTS_RUN: Input accepted (score: $score)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "Test $TESTS_RUN: Expected acceptance but got score $score (threshold: 0.5)"
        log_error "  Input: $input"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ============================================================================
# TEST CASES
# ============================================================================

log_info "Starting SC-4 Scope Validation Tests..."
log_info "Testing scope validation algorithm for /04_fix command"
echo ""

# Test 1: Complex task with "refactor" keyword
log_info "Test 1: Reject complex task with 'refactor' keyword"
assert_rejected "Refactor entire authentication system" "Keyword: refactor"

# Test 2: Very long input (>200 chars)
log_info "Test 2: Reject very long input (>200 characters)"
long_input="Fix the bug in the authentication system where users are unable to login after password reset because the token validation is failing due to timezone mismatch between the frontend and backend which causes the token to appear expired even though it was just created"
assert_rejected "$long_input" "Input length >200"

# Test 3: Multiple files mentioned (>3)
log_info "Test 3: Reject task mentioning 4+ files"
assert_rejected "Fix bugs in auth.ts, user.ts, session.ts, and token.ts" "File count >3"

# Test 4: Multiple tasks with AND connector
log_info "Test 4: Reject multiple tasks with AND connector"
assert_rejected "Fix the null pointer AND add validation AND update tests" "Multiple tasks"

# Test 5: Architecture keyword
log_info "Test 5: Reject task with 'architecture' keyword"
assert_rejected "Redesign architecture for user management system" "Keyword: architecture"

# Test 6: Combined complexity (long + keyword)
log_info "Test 6: Reject task with combined complexity factors"
combined="This is a very long description that exceeds two hundred characters because we want to test the complexity score calculation and also includes the keyword refactor which should trigger rejection"
assert_rejected "$combined" "Combined: length + keyword"

# Test 7: Simple task (should accept)
log_info "Test 7: Accept simple one-line fix"
assert_accepted "Fix typo in README.md line 10"

# Test 8: Simple task with single file (should accept)
log_info "Test 8: Accept simple bug fix in single file"
assert_accepted "Fix null pointer in auth.ts line 45"

# Test 9: Simple validation task (should accept)
log_info "Test 9: Accept simple validation addition"
assert_accepted "Add email validation to registration form"

# Test 10: Edge case: exactly 200 chars (should accept)
log_info "Test 10: Accept input exactly at threshold (200 chars)"
edge_200=$(printf 'a%.0s' {1..200})  # Creates 200-character string
assert_accepted "$edge_200"

# Test 11: Edge case: 201 chars (should reject)
log_info "Test 11: Reject input just over threshold (201 chars)"
edge_201=$(printf 'a%.0s' {1..201})  # Creates 201-character string
assert_rejected "$edge_201" "Input length >200"

# Test 12: Exactly 3 files (should accept)
log_info "Test 12: Accept task mentioning exactly 3 files"
assert_accepted "Fix issues in auth.ts, user.ts, and session.ts"

# Test 13: 4 files (should reject)
log_info "Test 13: Reject task mentioning 4 files"
assert_rejected "Fix issues in auth.ts, user.ts, session.ts, and token.ts" "File count >3"

# Test 14: Tradeoff keyword (should reject)
log_info "Test 14: Reject task with 'tradeoff' keyword"
assert_rejected "Analyze tradeoffs between caching strategies" "Keyword: tradeoff"

# Test 15: Design keyword (should reject)
log_info "Test 15: Reject task with 'design' keyword"
assert_rejected "Design new notification system" "Keyword: design"

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo ""
log_info "Test Summary:"
echo "----------------------------------------"
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "----------------------------------------"

if [ $TESTS_FAILED -eq 0 ]; then
    log_success "All scope validation tests passed!"
    exit 0
else
    log_error "Some tests failed!"
    exit 1
fi
