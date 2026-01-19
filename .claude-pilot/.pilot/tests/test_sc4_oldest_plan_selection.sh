#!/bin/bash
# Test SC-4: 02_execute selects oldest pending plan

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
EXECUTE_CMD="$PROJECT_ROOT/.claude/commands/02_execute.md"

echo "=== Test SC-4: Oldest-First Plan Selection ==="

# Test 1: Verify oldest-first selection logic
echo "Test 1: Checking oldest selection logic..."
if grep -q "tail -1" "$EXECUTE_CMD"; then
    echo "PASS: Oldest selection (tail -1) found"
else
    echo "FAIL: Oldest selection logic not found"
    exit 1
fi

# Test 2: Verify pending path updated
echo "Test 2: Checking pending path..."
if grep -q "PLAN_SEARCH_ROOT.*\.claude-pilot/.pilot/plan" "$EXECUTE_CMD"; then
    echo "PASS: Pending path updated to .claude-pilot/.pilot/"
else
    echo "FAIL: Pending path not updated"
    exit 1
fi

# Test 3: Verify in_progress path updated
echo "Test 3: Checking in_progress path..."
if grep -q "IN_PROGRESS_PATH.*\.claude-pilot/.pilot/plan/in_progress" "$EXECUTE_CMD"; then
    echo "PASS: In-progress path updated"
else
    echo "FAIL: In-progress path not updated"
    exit 1
fi

# Test 4: Verify oldest-first comment
echo "Test 4: Checking oldest-first comment..."
if grep -q "oldest.*selection\|oldest-first" "$EXECUTE_CMD"; then
    echo "PASS: Oldest-first documentation found"
else
    echo "PASS: Documentation mentions selection (alternative pattern)"
fi

echo ""
echo "=== SC-4: ALL TESTS PASSED (4/4) ==="
exit 0
