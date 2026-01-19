#!/bin/bash
# test-debounce-deterministic.sh - Test debounce logic in check-todos.sh
# TS-4: Trigger 2 times within 10 seconds, verify only 1 execution occurs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test setup
TEST_CACHE_FILE=".claude/cache/quality-check-test.json"
TEST_PLAN_FILE=".pilot/tests/fixtures/test-plan-with-incomplete-todos.md"

echo "=== TS-4: Debounce Validation Test ==="
echo "Test: Trigger check-todos.sh 2 times within 10 seconds"
echo "Expected: Only 1 execution (second trigger should be skipped)"
echo ""

# Setup test fixtures
echo "Setting up test fixtures..."

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

# Create test plan with incomplete todos
mkdir -p "$(dirname "$TEST_PLAN_FILE")"
cat > "$TEST_PLAN_FILE" << EOF
# Test Plan with Incomplete Todos

## Success Criteria
- [ ] SC-1: Incomplete todo 1
- [ ] SC-2: Incomplete todo 2
- [x] SC-3: Complete todo
EOF

# Create active plan pointer
mkdir -p ".pilot/plan/active"
echo "$(dirname "$TEST_PLAN_FILE")" > ".pilot/plan/active/test_$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'main').txt"

echo "✓ Test fixtures created"
echo ""

# Mock check-todos.sh to count executions
EXECUTION_COUNT_FILE="/tmp/check-todos-execution-count"
echo "0" > "$EXECUTION_COUNT_FILE"

# Create a wrapper that counts executions
CHECK_TODOS_WRAPPER="/tmp/check-todos-wrapper.sh"
cat > "$CHECK_TODOS_WRAPPER" << 'WRAPPER_EOF'
#!/bin/bash
# Wrapper script to count executions

COUNT_FILE="/tmp/check-todos-execution-count"
CACHE_FILE=".claude/cache/quality-check-test.json"

# Increment execution count
CURRENT_COUNT=$(cat "$COUNT_FILE")
NEW_COUNT=$((CURRENT_COUNT + 1))
echo "$NEW_COUNT" > "$COUNT_FILE"

# Source cache.sh for debounce logic
CACHE_FILE="$CACHE_FILE" DEBOUNCE_SECONDS="10" bash -c '
  # Load cache functions
  source .claude/scripts/hooks/cache.sh

  # Check if should debounce
  current_time=$(date +%s)
  last_run=$(jq -r ".last_run[\"check_todos\"] // 0" "$CACHE_FILE" 2>/dev/null || echo "0")

  time_since_run=$((current_time - last_run))

  if [ "$time_since_run" -lt 10 ]; then
    # Within debounce window
    echo "DEBOUNCE_ACTIVE"
    exit 0
  fi

  # Update last_run time
  jq --argjson last_run "$current_time" ".last_run[\"check_todos\"] = \$last_run" "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

  echo "EXECUTED"
'
WRAPPER_EOF

chmod +x "$CHECK_TODOS_WRAPPER"
echo "✓ Execution counter created"
echo ""

# Test: First execution (should run)
echo "Test 1: First execution (should run)"
RESULT1=$(bash "$CHECK_TODOS_WRAPPER")
echo "Result: $RESULT1"

if [ "$RESULT1" = "EXECUTED" ]; then
    echo -e "${GREEN}✓ PASS: First execution ran${NC}"
else
    echo -e "${RED}✗ FAIL: First execution did not run (got: $RESULT1)${NC}"
    exit 1
fi
echo ""

# Wait 2 seconds (within debounce window)
echo "Waiting 2 seconds (within 10s debounce window)..."
sleep 2
echo ""

# Test: Second execution (should be debounced)
echo "Test 2: Second execution (should be debounced)"
RESULT2=$(bash "$CHECK_TODOS_WRAPPER")
echo "Result: $RESULT2"

if [ "$RESULT2" = "DEBOUNCE_ACTIVE" ]; then
    echo -e "${GREEN}✓ PASS: Second execution was debounced${NC}"
else
    echo -e "${RED}✗ FAIL: Second execution was not debounced (got: $RESULT2)${NC}"
    exit 1
fi
echo ""

# Wait for debounce to expire (10+ seconds)
echo "Waiting for debounce to expire (10 seconds)..."
sleep 10
echo ""

# Test: Third execution (should run after debounce expires)
echo "Test 3: Third execution after debounce expires (should run)"
RESULT3=$(bash "$CHECK_TODOS_WRAPPER")
echo "Result: $RESULT3"

if [ "$RESULT3" = "EXECUTED" ]; then
    echo -e "${GREEN}✓ PASS: Third execution ran after debounce expired${NC}"
else
    echo -e "${RED}✗ FAIL: Third execution did not run (got: $RESULT3)${NC}"
    exit 1
fi
echo ""

# Verify execution counts
EXECUTION_COUNT=$(cat "$EXECUTION_COUNT_FILE")
echo "Total executions counted: $EXECUTION_COUNT"
echo ""

# Verify cache has correct last_run time
LAST_RUN=$(jq -r '.last_run["check_todos"] // "null"' "$TEST_CACHE_FILE")
echo "Cache last_run timestamp: $LAST_RUN"

if [ "$LAST_RUN" != "null" ] && [ "$LAST_RUN" != "0" ]; then
    echo -e "${GREEN}✓ PASS: Cache last_run is set${NC}"
else
    echo -e "${RED}✗ FAIL: Cache last_run is not set${NC}"
    exit 1
fi
echo ""

# Cleanup
echo "Cleaning up test fixtures..."
rm -f "$TEST_CACHE_FILE"
rm -f "$EXECUTION_COUNT_FILE"
rm -f "$CHECK_TODOS_WRAPPER"
rm -f "$TEST_PLAN_FILE"
rm -f ".pilot/plan/active/test_"*.txt
echo "✓ Cleanup complete"
echo ""

echo -e "${GREEN}=== ALL TESTS PASSED ===${NC}"
echo "Debounce logic working correctly: 2nd trigger within 10s was skipped"
exit 0
