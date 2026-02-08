#!/usr/bin/env bash
# Test: SC-7b confirm-plan migration verification

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Testing SC-7b: confirm-plan Agent Teams migration"

# Test 1: No subagent_type patterns
echo "Test 1: Verify no subagent_type occurrences"
SKILL_COUNT=$(grep -c "subagent_type" "$PROJECT_ROOT/.claude/skills/confirm-plan/SKILL.md" || true)
REF_COUNT=$(grep -c "subagent_type" "$PROJECT_ROOT/.claude/skills/confirm-plan/REFERENCE.md" || true)

if [ "$SKILL_COUNT" -eq 0 ] && [ "$REF_COUNT" -eq 0 ]; then
  echo "  ✓ PASS: No subagent_type patterns found"
else
  echo "  ✗ FAIL: Found subagent_type in SKILL.md=$SKILL_COUNT, REFERENCE.md=$REF_COUNT"
  exit 1
fi

# Test 2: Contains teammate patterns
echo "Test 2: Verify teammate patterns present"
if grep -q "teammate" "$PROJECT_ROOT/.claude/skills/confirm-plan/SKILL.md" && \
   grep -q "teammate" "$PROJECT_ROOT/.claude/skills/confirm-plan/REFERENCE.md"; then
  echo "  ✓ PASS: teammate patterns present"
else
  echo "  ✗ FAIL: teammate patterns missing"
  exit 1
fi

# Test 3: No orchestrator restrictions section
echo "Test 3: Verify MAIN ORCHESTRATOR RESTRICTIONS removed"
if grep -q "⛔ MAIN ORCHESTRATOR RESTRICTIONS" "$PROJECT_ROOT/.claude/skills/confirm-plan/SKILL.md"; then
  echo "  ✗ FAIL: MAIN ORCHESTRATOR RESTRICTIONS still present"
  exit 1
else
  echo "  ✓ PASS: MAIN ORCHESTRATOR RESTRICTIONS removed"
fi

# Test 4: Uses "team lead" terminology
echo "Test 4: Verify team lead terminology"
if grep -q "team lead" "$PROJECT_ROOT/.claude/skills/confirm-plan/SKILL.md" || \
   grep -q "Team Lead" "$PROJECT_ROOT/.claude/skills/confirm-plan/SKILL.md"; then
  echo "  ✓ PASS: team lead terminology present"
else
  echo "  ⚠ WARN: team lead terminology not found (optional)"
fi

echo ""
echo "✓ All SC-7b tests passed"
exit 0
