#!/bin/bash
# Test: /02_execute does NOT move plan to done
# TS-4: Plan 이동 금지 확인

set -e

echo "Testing: /02_execute does not move plan to done"

# Test 1: /02_execute does NOT contain mv command to move plan to done
echo "Test 1: No mv command to /pilot/plan/done/..."
if grep -q "mv.*\.pilot/plan/in_progress.*\.pilot/plan/done" .claude/commands/02_execute.md; then
    echo "✗ FAIL: /02_execute contains mv command to move plan to done"
    exit 1
else
    echo "✓ /02_execute does NOT move plan to done"
fi

# Test 2: Core Philosophy explicitly forbids moving to done
echo "Test 2: Core Philosophy forbids moving to done..."
if grep -A5 "## Core Philosophy" .claude/commands/02_execute.md | grep -q "NEVER move plan to done"; then
    echo "✓ Core Philosophy explicitly forbids moving to done"
else
    echo "✗ FAIL: Core Philosophy doesn't explicitly forbid moving to done"
    exit 1
fi

# Test 3: Step 0.5 warning explicitly says MUST NEVER move
echo "Test 3: Step 0.5 warning says MUST NEVER..."
if grep -A20 "## Step 0.5" .claude/commands/02_execute.md | grep -q "MUST NEVER"; then
    echo "✓ Step 0.5 warning says MUST NEVER move"
else
    echo "✗ FAIL: Step 0.5 warning doesn't say MUST NEVER"
    exit 1
fi

# Test 4: Success Criteria emphasizes plan stays in in_progress
echo "Test 4: Success Criteria emphasizes plan stays in in_progress..."
if grep -A20 "## Success Criteria" .claude/commands/02_execute.md | grep -q "MUST remain.*in_progress"; then
    echo "✓ Success Criteria emphasizes plan stays in in_progress"
else
    echo "✗ FAIL: Success Criteria doesn't emphasize plan stays in in_progress"
    exit 1
fi

# Test 5: Next Command section clarifies /03_close is the ONLY command that moves plans
echo "Test 5: Next Command clarifies /03_close is ONLY..."
if grep -A5 "## Next Command" .claude/commands/02_execute.md | grep -q "ONLY this command moves plans"; then
    echo "✓ Next Command clarifies /03_close is ONLY command that moves plans"
else
    echo "✗ FAIL: Next Command doesn't clarify /03_close is ONLY command"
    exit 1
fi

echo ""
echo "✅ All plan movement prohibition tests passed!"
