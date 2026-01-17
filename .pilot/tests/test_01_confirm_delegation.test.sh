#!/bin/bash
# Test: GPT delegation trigger in /01_confirm
# TS-2: /01_confirm should trigger GPT Plan Reviewer delegation for large plans (5+ SCs)

set -euo pipefail

# Test setup
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/../.." && pwd)"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/01_confirm.md"

echo "=== TS-2: GPT Delegation Trigger in /01_confirm ==="

# Test 1: Check GPT Delegation Trigger Check section exists
echo "Test 1: Checking for 'GPT Delegation Trigger Check' section..."
if grep -q "GPT Delegation Trigger Check" "$COMMAND_FILE"; then
    echo "✅ PASS: GPT Delegation Trigger Check section found"
else
    echo "❌ FAIL: GPT Delegation Trigger Check section NOT found"
    exit 1
fi

# Test 2: Check for Plan Reviewer expert in trigger table
echo "Test 2: Checking for Plan Reviewer expert in trigger table..."
if grep -i "Delegate to GPT Plan Reviewer" "$COMMAND_FILE" | grep -qi "5.*sc\|success criteria" > /dev/null 2>&1; then
    echo "✅ PASS: Plan Reviewer expert trigger found"
else
    echo "❌ FAIL: Plan Reviewer expert trigger NOT found"
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
echo "=== All tests PASSED for /01_confirm ==="
exit 0
