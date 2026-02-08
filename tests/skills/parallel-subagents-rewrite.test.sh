#!/bin/bash
# Test: parallel-subagents rewrite for Agent Teams
# Verify: terminology migration, content patterns, removal of old references

set -e

SKILL_FILE="/Users/chanho/claude-pilot/.claude/skills/parallel-subagents/SKILL.md"
REFERENCE_FILE="/Users/chanho/claude-pilot/.claude/skills/parallel-subagents/REFERENCE.md"

echo "=== SC-8: parallel-subagents Agent Teams Rewrite Tests ==="

# Test 1: No subagent_type references
echo "Test 1: Verify no 'subagent_type' references remain"
if grep -q "subagent_type" "$SKILL_FILE" "$REFERENCE_FILE"; then
    SUBAGENT_TYPE_COUNT=$(grep "subagent_type" "$SKILL_FILE" "$REFERENCE_FILE" | wc -l)
    echo "❌ FAIL: Found $SUBAGENT_TYPE_COUNT subagent_type references"
    grep -n "subagent_type" "$SKILL_FILE" "$REFERENCE_FILE"
    exit 1
else
    echo "✅ PASS: No subagent_type references found"
fi

# Test 2: New terminology present (teammate, Team Lead, spawn)
echo "Test 2: Verify Agent Teams terminology present"
if grep -q "teammate" "$SKILL_FILE" && \
   grep -q "Team Lead" "$SKILL_FILE" && \
   grep -q "Spawn teammate" "$SKILL_FILE"; then
    echo "✅ PASS: Agent Teams terminology present in SKILL.md"
else
    echo "❌ FAIL: Missing Agent Teams terminology in SKILL.md"
    exit 1
fi

if grep -q "teammate" "$REFERENCE_FILE" && \
   grep -q "Team Lead" "$REFERENCE_FILE"; then
    echo "✅ PASS: Agent Teams terminology present in REFERENCE.md"
else
    echo "❌ FAIL: Missing Agent Teams terminology in REFERENCE.md"
    exit 1
fi

# Test 3: Key pattern transformation present
echo "Test 3: Verify parallel execution pattern transformation"
if grep -q "Multiple teammates spawned simultaneously" "$SKILL_FILE"; then
    echo "✅ PASS: New parallel pattern documented"
else
    echo "❌ FAIL: Missing new parallel pattern"
    exit 1
fi

# Test 4: No "orchestrator" references (should be "Team Lead")
echo "Test 4: Verify orchestrator → Team Lead replacement"
ORCHESTRATOR_COUNT=$(grep -ci "orchestrator" "$SKILL_FILE" "$REFERENCE_FILE" || echo "0")
if [ "$ORCHESTRATOR_COUNT" -eq 0 ]; then
    echo "✅ PASS: No orchestrator references (replaced with Team Lead)"
else
    echo "⚠️  WARNING: Found $ORCHESTRATOR_COUNT orchestrator references (review if appropriate)"
fi

# Test 5: No MAIN ORCHESTRATOR RESTRICTIONS section
echo "Test 5: Verify no MAIN ORCHESTRATOR RESTRICTIONS section"
if ! grep -q "⛔ MAIN ORCHESTRATOR RESTRICTIONS" "$SKILL_FILE" "$REFERENCE_FILE"; then
    echo "✅ PASS: MAIN ORCHESTRATOR RESTRICTIONS section removed"
else
    echo "❌ FAIL: MAIN ORCHESTRATOR RESTRICTIONS section still present"
    exit 1
fi

# Test 6: Dependency analysis preserved
echo "Test 6: Verify dependency analysis preserved"
if grep -q "File Overlap" "$SKILL_FILE" "$REFERENCE_FILE" && \
   grep -q "Dependency Keywords" "$SKILL_FILE" "$REFERENCE_FILE"; then
    echo "✅ PASS: Dependency analysis patterns preserved"
else
    echo "❌ FAIL: Dependency analysis patterns missing"
    exit 1
fi

# Test 7: Test concurrency patterns preserved
echo "Test 7: Verify test concurrency patterns preserved"
if grep -q "E2E.*sequential" "$SKILL_FILE" && \
   grep -q "unit.*parallel" "$SKILL_FILE"; then
    echo "✅ PASS: Test concurrency patterns preserved"
else
    echo "❌ FAIL: Test concurrency patterns missing"
    exit 1
fi

# Test 8: Single Teammate Delegation pattern present
echo "Test 8: Verify Single Teammate Delegation pattern"
if grep -q "Single.*Delegation" "$SKILL_FILE" && \
   grep -q "teammate" "$SKILL_FILE"; then
    echo "✅ PASS: Single Teammate Delegation pattern present"
else
    echo "❌ FAIL: Single Teammate Delegation pattern missing"
    exit 1
fi

# Test 9: delegate mode reference present
echo "Test 9: Verify delegate mode reference"
if grep -q "delegate mode" "$SKILL_FILE" "$REFERENCE_FILE"; then
    echo "✅ PASS: Delegate mode reference present"
else
    echo "❌ FAIL: Delegate mode reference missing"
    exit 1
fi

# Test 10: File structure preserved (frontmatter, sections)
echo "Test 10: Verify file structure preserved"
if grep -q "^---$" "$SKILL_FILE" && \
   grep -q "^# SKILL: " "$SKILL_FILE" && \
   grep -q "## Quick Start" "$SKILL_FILE" && \
   grep -q "## Further Reading" "$SKILL_FILE"; then
    echo "✅ PASS: SKILL.md structure preserved"
else
    echo "❌ FAIL: SKILL.md structure broken"
    exit 1
fi

if grep -q "^# REFERENCE: " "$REFERENCE_FILE"; then
    echo "✅ PASS: REFERENCE.md structure preserved"
else
    echo "❌ FAIL: REFERENCE.md structure broken"
    exit 1
fi

echo ""
echo "=== All Tests Passed ==="
exit 0
