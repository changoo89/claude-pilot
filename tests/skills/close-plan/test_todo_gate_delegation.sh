#!/bin/bash
# Test: TODO Gate Validator Delegation
# Verifies that Step 1 delegates to validator agent before user escalation

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
REFERENCE_FILE="$PROJECT_ROOT/.claude/skills/close-plan/REFERENCE.md"

echo "Testing SC-6: TODO Gate Validator Delegation"

# Test 1: Verify Task tool delegation pattern exists in REFERENCE.md
echo "Test 1: Verify Task tool delegation pattern in REFERENCE.md"
if grep -q "Task: subagent_type: validator" "$REFERENCE_FILE"; then
    echo "✓ Task delegation pattern found"
else
    echo "✗ Task delegation pattern NOT found"
    exit 1
fi

# Test 2: Verify delegation happens BEFORE user escalation
echo "Test 2: Verify delegation occurs before user escalation"
if grep -B 10 "Task: subagent_type: validator" "$REFERENCE_FILE" | grep -q "TODO"; then
    echo "✓ Delegation pattern in TODO Gate section"
else
    echo "✗ Delegation pattern not in TODO Gate context"
    exit 1
fi

# Test 3: Verify validator analyzes unchecked TODOs
echo "Test 3: Verify validator prompt includes TODO analysis"
if grep -A 5 "Task: subagent_type: validator" "$REFERENCE_FILE" | grep -q "TODO"; then
    echo "✓ Validator prompt includes TODO analysis"
else
    echo "✗ Validator prompt missing TODO context"
    exit 1
fi

echo ""
echo "All tests passed ✓"
