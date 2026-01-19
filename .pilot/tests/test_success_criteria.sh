#!/bin/bash
# Test: Success Criteria includes plan status requirement
# TS-3: Success Criteria 확인

set -e

echo "Testing: Success Criteria in /02_execute"

# Test 1: Success Criteria section exists
echo "Test 1: Success Criteria section exists..."
if grep -q "## Success Criteria" .claude/commands/02_execute.md; then
    echo "✓ Success Criteria section exists"
else
    echo "✗ FAIL: Success Criteria section missing"
    exit 1
fi

# Test 2: Success Criteria has plan status requirement
echo "Test 2: Plan status requirement..."
if grep -A10 "## Success Criteria" .claude/commands/02_execute.md | grep -q "Plan MUST remain"; then
    echo "✓ Success Criteria has plan status requirement"
else
    echo "✗ FAIL: Success Criteria missing plan status requirement"
    exit 1
fi

# Test 3: Requirement mentions in_progress directory
echo "Test 3: in_progress directory mentioned..."
if grep -A10 "## Success Criteria" .claude/commands/02_execute.md | grep -q ".pilot/plan/in_progress/"; then
    echo "✓ Requirement mentions in_progress directory"
else
    echo "✗ FAIL: Requirement doesn't mention in_progress directory"
    exit 1
fi

# Test 4: Requirement says NEVER move to done
echo "Test 4: NEVER move to done mentioned..."
if grep -A10 "## Success Criteria" .claude/commands/02_execute.md | grep -q "NEVER move to done"; then
    echo "✓ Requirement says NEVER move to done"
else
    echo "✗ FAIL: Requirement doesn't say NEVER move to done"
    exit 1
fi

# Test 5: Requirement mentions /03_close
echo "Test 5: /03_close mentioned in requirement..."
if grep -A10 "## Success Criteria" .claude/commands/02_execute.md | grep -q "/03_close"; then
    echo "✓ Requirement mentions /03_close"
else
    echo "✗ FAIL: Requirement doesn't mention /03_close"
    exit 1
fi

echo ""
echo "✅ All Success Criteria tests passed!"
