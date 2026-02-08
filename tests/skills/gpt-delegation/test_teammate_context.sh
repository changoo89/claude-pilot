#!/usr/bin/env bash
# Test: GPT Delegation - Teammate Context Migration
# Verifies SC-9b requirements for teammate-based GPT delegation

set -e

SKILL_PATH="/Users/chanho/claude-pilot/.claude/skills/gpt-delegation"
FAILURES=0

echo "=== GPT Delegation Teammate Context Test ==="

# Test 1: Verify "subagent" terminology removed
echo -n "Test 1: 'subagent' terminology removed... "
SUBAGENT_COUNT=$(grep -h "subagent" "$SKILL_PATH/SKILL.md" "$SKILL_PATH/REFERENCE.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SUBAGENT_COUNT" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL (found $SUBAGENT_COUNT instances of 'subagent')"
  FAILURES=$((FAILURES + 1))
fi

# Test 2: Verify "teammate" terminology added
echo -n "Test 2: 'teammate' terminology added... "
TEAMMATE_COUNT=$(grep -hE "teammate|Teammate" "$SKILL_PATH/SKILL.md" "$SKILL_PATH/REFERENCE.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEAMMATE_COUNT" -ge 3 ]; then
  echo "PASS (found $TEAMMATE_COUNT instances)"
else
  echo "FAIL (expected >= 3, found $TEAMMATE_COUNT)"
  FAILURES=$((FAILURES + 1))
fi

# Test 3: Verify "Team Lead" terminology added
echo -n "Test 3: 'Team Lead' terminology added... "
TEAM_LEAD_COUNT=$(grep -h "Team Lead" "$SKILL_PATH/SKILL.md" "$SKILL_PATH/REFERENCE.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEAM_LEAD_COUNT" -ge 1 ]; then
  echo "PASS (found $TEAM_LEAD_COUNT instances)"
else
  echo "FAIL (expected >= 1, found $TEAM_LEAD_COUNT)"
  FAILURES=$((FAILURES + 1))
fi

# Test 4: Verify graceful fallback pattern preserved
echo -n "Test 4: Graceful fallback pattern preserved... "
if grep -q "command -v codex" "$SKILL_PATH/SKILL.md" && \
   grep -q "falling back to Claude" "$SKILL_PATH/SKILL.md"; then
  echo "PASS"
else
  echo "FAIL (graceful fallback pattern missing)"
  FAILURES=$((FAILURES + 1))
fi

# Test 5: Verify confidence rubric preserved
echo -n "Test 5: Confidence rubric preserved... "
if grep -q "confidence.*0\\.5" "$SKILL_PATH/SKILL.md" && \
   grep -q "architecture_keywords\|multiple_approaches\|uncertainty" "$SKILL_PATH/SKILL.md"; then
  echo "PASS"
else
  echo "FAIL (confidence rubric missing or incomplete)"
  FAILURES=$((FAILURES + 1))
fi

# Test 6: Verify codex CLI parameters unchanged
echo -n "Test 6: Codex CLI parameters unchanged... "
if grep -q "codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium" "$SKILL_PATH/SKILL.md" && \
   grep -q "codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium" "$SKILL_PATH/SKILL.md"; then
  echo "PASS"
else
  echo "FAIL (codex CLI parameters changed)"
  FAILURES=$((FAILURES + 1))
fi

# Test 7: Verify integration pattern updated (Coder Agent → Coder Teammate)
echo -n "Test 7: Integration pattern updated to Teammate... "
if grep -q "Coder.*Teammate\|Teammate.*Ralph Loop" "$SKILL_PATH/SKILL.md"; then
  echo "PASS"
else
  echo "FAIL (integration pattern not updated)"
  FAILURES=$((FAILURES + 1))
fi

# Test 8: Verify CODER_BLOCKED → messaging pattern
echo -n "Test 8: CODER_BLOCKED messaging pattern updated... "
if grep -q "message.*Team Lead\|Team Lead.*blocked" "$SKILL_PATH/SKILL.md" "$SKILL_PATH/REFERENCE.md" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL (messaging pattern not updated)"
  FAILURES=$((FAILURES + 1))
fi

# Test 9: Verify progressive escalation preserved
echo -n "Test 9: Progressive escalation pattern preserved... "
if grep -q "Progressive [Ee]scalation" "$SKILL_PATH/SKILL.md" && \
   grep -q "2+ failed\|2nd failure" "$SKILL_PATH/SKILL.md"; then
  echo "PASS"
else
  echo "FAIL (progressive escalation missing)"
  FAILURES=$((FAILURES + 1))
fi

# Test 10: Verify teammate shares GPT results via Message
echo -n "Test 10: Teammate shares GPT results... "
if grep -q "share.*GPT\|GPT.*teammate\|Message.*GPT" "$SKILL_PATH/SKILL.md" "$SKILL_PATH/REFERENCE.md" 2>/dev/null; then
  echo "PASS"
else
  echo "FAIL (GPT result sharing pattern missing)"
  FAILURES=$((FAILURES + 1))
fi

echo ""
if [ $FAILURES -eq 0 ]; then
  echo "✅ All tests passed"
  exit 0
else
  echo "❌ $FAILURES test(s) failed"
  exit 1
fi
