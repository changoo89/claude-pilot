#!/bin/bash
# Test: GPT delegation trigger in /00_plan
# TS-1: /00_plan should trigger GPT Architect delegation for architecture decisions

set -euo pipefail

# Test setup
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/../.." && pwd)"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/00_plan.md"

echo "=== TS-1: GPT Delegation Trigger in /00_plan ==="

# Test 1: Check GPT Delegation Trigger Check section exists
echo "Test 1: Checking for 'GPT Delegation Trigger Check' section..."
if grep -q "GPT Delegation Trigger Check" "$COMMAND_FILE"; then
    echo "✅ PASS: GPT Delegation Trigger Check section found"
else
    echo "❌ FAIL: GPT Delegation Trigger Check section NOT found"
    exit 1
fi

# Test 2: Check for Architect expert in trigger table
echo "Test 2: Checking for Architect expert in trigger table..."
if grep -i "Delegate to GPT Architect" "$COMMAND_FILE" | grep -qi "tradeoff\|design\|structure\|architecture" > /dev/null 2>&1; then
    echo "✅ PASS: Architect expert trigger found"
else
    echo "❌ FAIL: Architect expert trigger NOT found"
    exit 1
fi

# Test 3: Check for graceful fallback pattern
echo "Test 3: Checking for graceful fallback pattern..."
if grep -A3 "command -v codex" "$COMMAND_FILE" | grep -q "return 0"; then
    echo "✅ PASS: Graceful fallback pattern found"
else
    echo "❌ FAIL: Graceful fallback pattern NOT found"
    exit 1
fi

# Test 4: Check for link to triggers.md
echo "Test 4: Checking for link to triggers.md..."
if grep -q "delegator/triggers.md" "$COMMAND_FILE"; then
    echo "✅ PASS: Link to triggers.md found"
else
    echo "❌ FAIL: Link to triggers.md NOT found"
    exit 1
fi

echo ""
echo "=== All tests PASSED for /00_plan ==="
exit 0
