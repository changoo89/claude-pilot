#!/bin/bash
# test-check-todos-integration.sh - Integration test for check-todos.sh with debounce
# Verifies the complete flow: debounce logic + cache integration + todo checking

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== Integration Test: check-todos.sh with Debounce ==="
echo ""

# Test setup
TEST_CACHE_FILE=".claude/cache/quality-check-integration.json"
TEST_RUN_DIR=".pilot/tests/fixtures/integration-test"
TEST_PLAN_FILE="$TEST_RUN_DIR/plan.md"

# Setup test fixtures
echo "Setting up integration test fixtures..."

# Create test cache directory
mkdir -p "$(dirname "$TEST_CACHE_FILE")"

# Initialize cache file
cat > "$TEST_CACHE_FILE" << EOF
{
  "version": 1,
  "repository": "test-repo",
  "detected_at": 0,
  "project_type": "typescript",
  "tools": {},
  "last_run": {},
  "config_hashes": {},
  "profile": {
    "mode": "stop"
  }
}
EOF

# Create test plan with incomplete todos (must be named plan.md)
mkdir -p "$(dirname "$TEST_PLAN_FILE")"
cat > "$TEST_PLAN_FILE" << EOF
# Integration Test Plan

## Success Criteria
- [ ] SC-1: Incomplete todo for integration test
- [x] SC-2: Complete todo
EOF

# The check-todos.sh script looks for plan.md in the RUN_DIR
# So TEST_PLAN_FILE should be $RUN_DIR/plan.md

# Create active plan pointer (matching current branch)
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'main')"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"

mkdir -p ".pilot/plan/active"
echo "$TEST_RUN_DIR" > ".pilot/plan/active/${KEY}.txt"

# Create in_progress directory structure
mkdir -p ".pilot/plan/in_progress"

echo "✓ Test fixtures created"
echo ""

# Test 1: First run (should execute)
echo "Test 1: First run (should execute and warn about incomplete todos)"
export CACHE_FILE="$TEST_CACHE_FILE"
export DEBOUNCE_SECONDS="5"

OUTPUT1=$(bash .claude/scripts/hooks/check-todos.sh 2>&1 || true)
echo "$OUTPUT1"

if echo "$OUTPUT1" | grep -q "incomplete todo"; then
    echo -e "${GREEN}✓ PASS: First execution detected incomplete todos${NC}"
else
    echo -e "${RED}✗ FAIL: First execution did not detect incomplete todos${NC}"
    exit 1
fi
echo ""

# Test 2: Second run immediately (should be debounced)
echo "Test 2: Second run immediately (should be debounced)"
OUTPUT2=$(bash .claude/scripts/hooks/check-todos.sh 2>&1 || true)
echo "$OUTPUT2"

if echo "$OUTPUT2" | grep -q "Debounced"; then
    echo -e "${GREEN}✓ PASS: Second execution was debounced${NC}"
else
    echo -e "${RED}✗ FAIL: Second execution was not debounced${NC}"
    echo "Expected 'Debounced' in output"
    exit 1
fi
echo ""

# Test 3: Wait for debounce to expire
echo "Test 3: Wait for debounce to expire (5 seconds)..."
sleep 5
echo ""

# Test 4: Third run after debounce expires (should execute)
echo "Test 4: Third run after debounce expires (should execute)"
OUTPUT3=$(bash .claude/scripts/hooks/check-todos.sh 2>&1 || true)
echo "$OUTPUT3"

if echo "$OUTPUT3" | grep -q "incomplete todo"; then
    echo -e "${GREEN}✓ PASS: Third execution detected incomplete todos after debounce expired${NC}"
else
    echo -e "${RED}✗ FAIL: Third execution did not detect incomplete todos${NC}"
    exit 1
fi
echo ""

# Test 5: Verify cache has correct last_run time
echo "Test 5: Verify cache state"
LAST_RUN=$(jq -r '.last_run["check_todos"] // "null"' "$TEST_CACHE_FILE")
echo "Cache last_run timestamp: $LAST_RUN"

if [ "$LAST_RUN" != "null" ] && [ "$LAST_RUN" != "0" ]; then
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_RUN))

    if [ "$TIME_DIFF" -lt 5 ]; then
        echo -e "${GREEN}✓ PASS: Cache last_run is recent (${TIME_DIFF}s ago)${NC}"
    else
        echo -e "${YELLOW}⚠ WARNING: Cache last_run is stale (${TIME_DIFF}s ago)${NC}"
    fi
else
    echo -e "${RED}✗ FAIL: Cache last_run is not set${NC}"
    exit 1
fi
echo ""

# Test 6: Complete all todos and verify success message
echo "Test 6: Complete all todos and verify success message"
cat > "$TEST_PLAN_FILE" << EOF
# Integration Test Plan

## Success Criteria
- [x] SC-1: Complete todo 1
- [x] SC-2: Complete todo 2
EOF

# Wait for debounce to expire
sleep 5

OUTPUT4=$(bash .claude/scripts/hooks/check-todos.sh 2>&1 || true)
echo "$OUTPUT4"

if echo "$OUTPUT4" | grep -q "All todos completed"; then
    echo -e "${GREEN}✓ PASS: Success message displayed when all todos complete${NC}"
else
    echo -e "${RED}✗ FAIL: Success message not displayed${NC}"
    exit 1
fi
echo ""

# Cleanup
echo "Cleaning up test fixtures..."
rm -f "$TEST_CACHE_FILE"
rm -f "$TEST_PLAN_FILE"
rm -f ".pilot/plan/active/${KEY}.txt"
echo "✓ Cleanup complete"
echo ""

echo -e "${GREEN}=== ALL INTEGRATION TESTS PASSED ===${NC}"
echo "check-todos.sh with debounce logic working correctly"
exit 0
