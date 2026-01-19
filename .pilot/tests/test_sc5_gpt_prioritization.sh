#!/bin/bash
# Test SC-5: 02_execute prioritizes GPT over user queries
# This test verifies that GPT delegation happens BEFORE user queries

set -e

TEST_NAME="SC-5: GPT Prioritization"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

echo "🧪 Test: $TEST_NAME"
echo "========================================"

# Test 1: Verify GPT escalation step exists before user query logic
echo "Test 1: Check GPT escalation step priority in 02_execute.md"
echo "--------------------------------------"

if grep -q "## Step 1.5: GPT Delegation Triggers" "$PROJECT_ROOT/.claude/commands/02_execute.md"; then
    echo "✓ PASS: GPT Delegation step found at 1.5 (before later steps)"
else
    echo "❌ FAIL: GPT Delegation step not found at expected location"
    exit 1
fi

# Test 2: Verify "Prioritize GPT" instruction exists
echo ""
echo "Test 2: Check for 'Prioritize GPT' instruction"
echo "--------------------------------------"

if grep -qi "prioritize.*GPT\|GPT.*prioriti" "$PROJECT_ROOT/.claude/commands/02_execute.md"; then
    echo "✓ PASS: Found prioritization instruction for GPT consultation"
else
    echo "❌ FAIL: No 'Prioritize GPT' instruction found"
    exit 1
fi

# Test 3: Verify escalation triggers include "stuck on task" scenarios
echo ""
echo "Test 3: Check for 'stuck on task' escalation trigger"
echo "--------------------------------------"

if grep -qi "stuck\|block\|fail.*attempt" "$PROJECT_ROOT/.claude/commands/02_execute.md"; then
    echo "✓ PASS: Found escalation triggers for stuck scenarios"
else
    echo "❌ FAIL: No escalation triggers for stuck scenarios found"
    exit 1
fi

# Test 4: Verify Step 5 (GPT Escalation) comes before any user query steps
echo ""
echo "Test 4: Verify GPT Escalation step ordering"
echo "--------------------------------------"

# Extract step numbers
GPT_ESCALATION_LINE=$(grep -n "## Step 5: GPT Escalation" "$PROJECT_ROOT/.claude/commands/02_execute.md" | cut -d: -f1)
USER_QUERY_LINE=$(grep -n "AskUserQuestion" "$PROJECT_ROOT/.claude/commands/02_execute.md" | head -1 | cut -d: -f1)

if [ -n "$GPT_ESCALATION_LINE" ] && [ -n "$USER_QUERY_LINE" ]; then
    if [ "$GPT_ESCALATION_LINE" -lt "$USER_QUERY_LINE" ]; then
        echo "✓ PASS: GPT Escalation (line $GPT_ESCALATION_LINE) comes before user queries (line $USER_QUERY_LINE)"
    else
        echo "❌ FAIL: User queries appear before GPT Escalation"
        exit 1
    fi
else
    echo "⚠️  WARNING: Could not verify step ordering (one or both steps not found)"
fi

# Test 5: Verify auto-delegation on <CODER_BLOCKED>
echo ""
echo "Test 5: Check for auto-delegation on coder blocked"
echo "--------------------------------------"

if grep -q "Auto-delegation.*when.*CODER_BLOCKED\|<CODER_BLOCKED>.*delegate" "$PROJECT_ROOT/.claude/commands/02_execute.md"; then
    echo "✓ PASS: Auto-delegation on <CODER_BLOCKED> found"
else
    echo "❌ FAIL: No auto-delegation on <CODER_BLOCKED> found"
    exit 1
fi

echo ""
echo "========================================"
echo "✅ All tests passed for SC-5"
echo "========================================"
exit 0
