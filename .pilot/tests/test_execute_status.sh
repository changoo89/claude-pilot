#!/bin/bash
# Test: Plan status remains in in_progress after /02_execute
# TS-1: Plan 상태 유지 확인

set -e

echo "Testing: Plan status after /02_execute completion"

# Check if /02_execute has phase boundary protection
echo "Checking /02_execute for phase boundary protection..."
if grep -q "Phase boundary protection" .claude/commands/02_execute.md; then
    echo "✓ Phase boundary protection warning exists"
else
    echo "✗ FAIL: Phase boundary protection warning missing"
    exit 1
fi

# Check if /02_execute has NEVER move plan warning
echo "Checking /02_execute for NEVER move plan warning..."
if grep -q "NEVER move plan to done" .claude/commands/02_execute.md; then
    echo "✓ NEVER move plan warning exists"
else
    echo "✗ FAIL: NEVER move plan warning missing"
    exit 1
fi

# Check if Success Criteria includes plan status requirement
echo "Checking Success Criteria for plan status requirement..."
if grep -q "Plan MUST remain" .claude/commands/02_execute.md; then
    echo "✓ Success Criteria includes plan status requirement"
else
    echo "✗ FAIL: Success Criteria missing plan status requirement"
    exit 1
fi

# Check if /03_close reference is strengthened
echo "Checking /03_close reference..."
if grep -q "REQUIRED.*Move plan to done.*ONLY this command" .claude/commands/02_execute.md; then
    echo "✓ /03_close reference is strengthened"
else
    echo "✗ FAIL: /03_close reference not strengthened"
    exit 1
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "Verification Summary:"
echo "  - Phase boundary protection: ✓"
echo "  - NEVER move plan warning: ✓"
echo "  - Success Criteria requirement: ✓"
echo "  - /03_close reference: ✓"
