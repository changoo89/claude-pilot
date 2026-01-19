#!/bin/bash
# Test: Prompt warnings exist in /02_execute
# TS-2: 프롬프트 경고 존재 확인

set -e

echo "Testing: Prompt warnings in /02_execute"

# Test 1: Core Philosophy section has phase boundary protection
echo "Test 1: Core Philosophy section..."
if grep -A5 "## Core Philosophy" .claude/commands/02_execute.md | grep -q "Phase boundary protection"; then
    echo "✓ Core Philosophy has phase boundary protection"
else
    echo "✗ FAIL: Core Philosophy missing phase boundary protection"
    exit 1
fi

# Test 2: Step 0.5 has NEVER move plan warning
echo "Test 2: Step 0.5 warning..."
if grep -A10 "## Step 0.5" .claude/commands/02_execute.md | grep -q "NEVER move the plan to done"; then
    echo "✓ Step 0.5 has NEVER move plan warning"
else
    echo "✗ FAIL: Step 0.5 missing NEVER move plan warning"
    exit 1
fi

# Test 3: Warning mentions /03_close responsibility
echo "Test 3: /03_close responsibility mentioned..."
if grep -A10 "## Step 0.5" .claude/commands/02_execute.md | grep -q "/03_close"; then
    echo "✓ Warning mentions /03_close responsibility"
else
    echo "✗ FAIL: Warning doesn't mention /03_close"
    exit 1
fi

echo ""
echo "✅ All prompt warning tests passed!"
