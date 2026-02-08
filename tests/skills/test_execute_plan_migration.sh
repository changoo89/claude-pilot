#!/bin/bash
# Test: execute-plan migration to Agent Teams

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
SKILL_FILE="$PROJECT_ROOT/.claude/skills/execute-plan/SKILL.md"
REFERENCE_FILE="$PROJECT_ROOT/.claude/skills/execute-plan/REFERENCE.md"

echo "Testing execute-plan migration to Agent Teams..."

# Test 1: No subagent_type patterns remain
echo "Test 1: Checking for subagent_type patterns..."
if grep -q "subagent_type" "$SKILL_FILE" "$REFERENCE_FILE" 2>/dev/null; then
    echo "❌ FAIL: Found subagent_type patterns"
    grep -n "subagent_type" "$SKILL_FILE" "$REFERENCE_FILE" || true
    exit 1
fi
echo "✓ PASS: No subagent_type patterns found"

# Test 2: No "subagent" word in SKILL.md (should be "teammate")
echo "Test 2: Checking for subagent references in SKILL.md..."
if grep -i "subagent" "$SKILL_FILE" 2>/dev/null; then
    echo "❌ FAIL: Found subagent references in SKILL.md"
    grep -n -i "subagent" "$SKILL_FILE" || true
    exit 1
fi
echo "✓ PASS: No subagent references in SKILL.md"

# Test 3: Teammate spawn pattern exists
echo "Test 3: Checking for teammate spawn patterns..."
if ! grep -q "Spawn teammate" "$SKILL_FILE" 2>/dev/null; then
    echo "❌ FAIL: Missing teammate spawn pattern"
    exit 1
fi
echo "✓ PASS: Teammate spawn pattern found"

# Test 4: Delegate mode mentioned
echo "Test 4: Checking for delegate mode..."
if ! grep -q "delegate mode" "$SKILL_FILE" 2>/dev/null; then
    echo "❌ FAIL: Missing delegate mode reference"
    exit 1
fi
echo "✓ PASS: Delegate mode reference found"

# Test 5: Team Lead terminology (not orchestrator)
echo "Test 5: Checking for Team Lead terminology..."
if grep -q "orchestrator" "$SKILL_FILE" 2>/dev/null | grep -v "# " | grep -v "main orchestrator" ; then
    echo "⚠️  WARNING: Found 'orchestrator' references (should be 'Team Lead')"
fi
if grep -q "[Tt]eam [Ll]ead" "$SKILL_FILE" 2>/dev/null; then
    echo "✓ PASS: Team Lead terminology found"
else
    echo "⚠️  WARNING: No Team Lead terminology found"
fi

# Test 6: No MAIN ORCHESTRATOR RESTRICTIONS section
echo "Test 6: Checking for removed restrictions section..."
if grep -q "MAIN ORCHESTRATOR RESTRICTIONS" "$SKILL_FILE" 2>/dev/null; then
    echo "❌ FAIL: Found MAIN ORCHESTRATOR RESTRICTIONS section (should be removed)"
    exit 1
fi
echo "✓ PASS: MAIN ORCHESTRATOR RESTRICTIONS section removed"

# Test 7: No Context Protection comments
echo "Test 7: Checking for Context Protection comments..."
if grep -q "Context Protection" "$SKILL_FILE" 2>/dev/null; then
    echo "⚠️  WARNING: Found Context Protection comments (native isolation replaces this)"
fi

echo ""
echo "All tests passed! ✅"
exit 0
