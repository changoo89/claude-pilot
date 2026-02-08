#!/bin/bash
# Test SC-12b: Tier 2 documentation updates for Agent Teams

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
AGENTS_CONTEXT="$PROJECT_ROOT/.claude/agents/CONTEXT.md"
COMMANDS_CONTEXT="$PROJECT_ROOT/.claude/commands/CONTEXT.md"
SKILLS_CONTEXT="$PROJECT_ROOT/.claude/skills/CONTEXT.md"

echo "Testing SC-12b: Tier 2 documentation updates..."

# Test 1: agents/CONTEXT.md must contain "teammate" references
echo "Test 1: Checking agents/CONTEXT.md for 'teammate' references..."
if grep -q "teammate" "$AGENTS_CONTEXT"; then
  echo "✓ PASS: Found 'teammate' in agents/CONTEXT.md"
else
  echo "✗ FAIL: 'teammate' not found in agents/CONTEXT.md"
  exit 1
fi

# Test 2: skills/CONTEXT.md must contain "agent-teams" skill reference
echo "Test 2: Checking skills/CONTEXT.md for 'agent-teams' skill..."
if grep -q "agent-teams" "$SKILLS_CONTEXT"; then
  echo "✓ PASS: Found 'agent-teams' in skills/CONTEXT.md"
else
  echo "✗ FAIL: 'agent-teams' not found in skills/CONTEXT.md"
  exit 1
fi

# Test 3: commands/CONTEXT.md must mention "Agent Teams"
echo "Test 3: Checking commands/CONTEXT.md for 'Agent Teams' references..."
if grep -q "Agent Teams" "$COMMANDS_CONTEXT"; then
  echo "✓ PASS: Found 'Agent Teams' in commands/CONTEXT.md"
else
  echo "✗ FAIL: 'Agent Teams' not found in commands/CONTEXT.md"
  exit 1
fi

# Test 4: agents/CONTEXT.md must have "Teammate Roles" section
echo "Test 4: Checking agents/CONTEXT.md for 'Teammate Roles' section..."
if grep -q "## Teammate Roles" "$AGENTS_CONTEXT"; then
  echo "✓ PASS: Found 'Teammate Roles' section in agents/CONTEXT.md"
else
  echo "✗ FAIL: 'Teammate Roles' section not found in agents/CONTEXT.md"
  exit 1
fi

# Test 5: agents/CONTEXT.md must have spawn_prompt pattern examples
echo "Test 5: Checking agents/CONTEXT.md for 'spawn_prompt' pattern..."
if grep -q "spawn_prompt" "$AGENTS_CONTEXT"; then
  echo "✓ PASS: Found 'spawn_prompt' pattern in agents/CONTEXT.md"
else
  echo "✗ FAIL: 'spawn_prompt' pattern not found in agents/CONTEXT.md"
  exit 1
fi

echo ""
echo "All tests passed! ✓"
exit 0
