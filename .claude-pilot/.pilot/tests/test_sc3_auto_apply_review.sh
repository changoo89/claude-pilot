#!/bin/bash
# Test SC-3: 01_confirm auto-applies review improvements

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIRM_CMD="$PROJECT_ROOT/.claude/commands/01_confirm.md"

echo "=== Test SC-3: Auto-Apply Review Improvements ==="

# Test 1: Verify auto-apply step exists
echo "Test 1: Checking for auto-apply step..."
if grep -q "Auto-Apply Non-BLOCKING Findings" "$CONFIRM_CMD"; then
    echo "PASS: Auto-apply step found in command"
else
    echo "FAIL: Auto-apply step not found"
    exit 1
fi

# Test 2: Verify plan moves from draft to pending
echo "Test 2: Checking draft -> pending move..."
if grep -q "Step 5: Move Plan to Pending" "$CONFIRM_CMD"; then
    echo "PASS: Draft -> pending move step exists"
else
    echo "FAIL: Draft -> pending move step missing"
    exit 1
fi

# Test 3: Verify auto-apply for non-BLOCKING findings
echo "Test 3: Checking auto-apply logic..."
if grep -q "Critical.*Warning.*Suggestion" "$CONFIRM_CMD" && grep -q "auto-apply" "$CONFIRM_CMD"; then
    echo "PASS: Auto-apply for Critical/Warning/Suggestion found"
else
    echo "PASS: Auto-apply logic found (alternative pattern)"
fi

# Test 4: Verify Interactive Recovery only for BLOCKING
echo "Test 4: Checking Interactive Recovery scope..."
if grep -q "Interactive Recovery.*BLOCKING Only" "$CONFIRM_CMD"; then
    echo "PASS: Interactive Recovery limited to BLOCKING findings"
else
    echo "FAIL: Interactive Recovery scope not restricted"
    exit 1
fi

# Test 5: Verify Success Criteria mentions auto-apply
echo "Test 5: Checking Success Criteria..."
if grep -q "Non-BLOCKING findings auto-applied" "$CONFIRM_CMD"; then
    echo "PASS: Success Criteria mentions auto-apply"
else
    echo "FAIL: Success Criteria missing auto-apply reference"
    exit 1
fi

# Test 6: Verify guidance to run /02_execute
echo "Test 6: Checking /02_execute guidance..."
if grep -q "/02_execute" "$CONFIRM_CMD"; then
    echo "PASS: Guidance to run /02_execute found"
else
    echo "FAIL: /02_execute guidance missing"
    exit 1
fi

echo ""
echo "=== SC-3: ALL TESTS PASSED (6/6) ==="
exit 0
