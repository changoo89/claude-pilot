#!/usr/bin/env bash
# Test SC-9c: TDD skill teammate terminology migration

set -e

echo "Test SC-9c: TDD teammate migration"

# Test 1: No "subagent" references in SKILL.md
if grep -q "subagent" .claude/skills/tdd/SKILL.md; then
  subagent_count=$(grep -o "subagent" .claude/skills/tdd/SKILL.md | wc -l | tr -d ' ')
  echo "FAIL: Found $subagent_count 'subagent' references in SKILL.md"
  exit 1
fi

# Test 2: "Teammates Only" warning present in SKILL.md
if ! grep -q "Teammates Only" .claude/skills/tdd/SKILL.md; then
  echo "FAIL: 'Teammates Only' warning not found in SKILL.md"
  exit 1
fi

# Test 3: "Team Lead" terminology present
if ! grep -q "Team Lead" .claude/skills/tdd/SKILL.md; then
  echo "FAIL: 'Team Lead' terminology not found in SKILL.md"
  exit 1
fi

# Test 4: No "subagent" references in REFERENCE.md
if grep -q "subagent" .claude/skills/tdd/REFERENCE.md; then
  ref_subagent_count=$(grep -o "subagent" .claude/skills/tdd/REFERENCE.md | wc -l | tr -d ' ')
  echo "FAIL: Found $ref_subagent_count 'subagent' references in REFERENCE.md"
  exit 1
fi

# Test 5: Core TDD concepts preserved (Red-Green-Refactor)
if ! grep -q "Red-Green-Refactor" .claude/skills/tdd/SKILL.md; then
  echo "FAIL: Red-Green-Refactor concept missing"
  exit 1
fi

# Test 6: Test-first methodology preserved
if ! grep -q "Test-first" .claude/skills/tdd/SKILL.md; then
  echo "FAIL: Test-first methodology missing"
  exit 1
fi

echo "✓ All SC-9c tests passed"
exit 0
