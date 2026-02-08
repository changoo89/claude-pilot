#!/bin/bash
# Test: Agent Delegation Before User Escalation (SC-2)
# Purpose: Verify Step 1.9/1.10 delegate to explorer/researcher before user escalation

set -e

REFERENCE_FILE="/Users/chanho/claude-pilot/.claude/skills/spec-driven-workflow/REFERENCE.md"

echo "Test: Agent Delegation Before User Escalation"
echo "=============================================="

# Test 1: Check for Task tool delegation pattern in Step 1.9
echo -n "Test 1: Check for Task delegation in Step 1.9... "
if grep -q "Task: subagent_type: explorer" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing 'Task: subagent_type: explorer' in Step 1.9"
  exit 1
fi

# Test 2: Check for researcher delegation in Step 1.9
echo -n "Test 2: Check for researcher delegation in Step 1.9... "
if grep -q "Task: subagent_type: researcher" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing 'Task: subagent_type: researcher' in Step 1.9"
  exit 1
fi

# Test 3: Verify delegation happens BEFORE AskUserQuestion
echo -n "Test 3: Check delegation before user escalation... "
if grep -A 10 "Step 1.9" "$REFERENCE_FILE" | grep -qi "before.*user.*escalation"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing explicit 'before user escalation' pattern"
  exit 1
fi

# Test 4: Verify Step 1.10 also has delegation pattern
echo -n "Test 4: Check for delegation in Step 1.10... "
if grep -A 50 "^### Step 1.10: Readiness Gate" "$REFERENCE_FILE" | grep -q "Task: subagent_type: explorer\|Task: subagent_type: researcher"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing Task delegation pattern in Step 1.10"
  exit 1
fi

# Test 5: Verify gap investigation is mentioned
echo -n "Test 5: Check for gap investigation pattern... "
if grep -q "gap investigation\|investigate gaps" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing 'gap investigation' pattern"
  exit 1
fi

echo ""
echo "All tests passed! ✓"
