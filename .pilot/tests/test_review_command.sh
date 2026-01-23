#!/usr/bin/env bash
# Test: SC-8 - review.md should be superpowers-style (< 20 lines)

set -euo pipefail

PROJECT_ROOT="/Users/chanho/claude-pilot"
COMMAND_FILE="$PROJECT_ROOT/.claude/commands/review.md"
SKILL_FILE="$PROJECT_ROOT/.claude/skills/review/SKILL.md"

echo "=== SC-8: Review Command Simplification Test ==="

# Test 1: Command file exists
if [ ! -f "$COMMAND_FILE" ]; then
    echo "❌ FAIL: review.md not found"
    exit 1
fi
echo "✓ Test 1: Command file exists"

# Test 2: Command file is < 20 lines
LINE_COUNT=$(wc -l < "$COMMAND_FILE" | tr -d ' ')
if [ "$LINE_COUNT" -ge 20 ]; then
    echo "❌ FAIL: review.md has $LINE_COUNT lines (expected < 20)"
    exit 1
fi
echo "✓ Test 2: Command file is $LINE_COUNT lines (< 20)"

# Test 3: Command file contains skill invocation
if ! grep -q "Invoke the.*skill" "$COMMAND_FILE"; then
    echo "❌ FAIL: Command file doesn't contain skill invocation"
    exit 1
fi
echo "✓ Test 3: Command contains skill invocation"

# Test 4: Command file passes arguments
if ! grep -q '\$ARGUMENTS' "$COMMAND_FILE"; then
    echo "❌ FAIL: Command file doesn't pass \$ARGUMENTS"
    exit 1
fi
echo "✓ Test 4: Command passes \$ARGUMENTS"

# Test 5: Command file has NO bash scripts (no ```)
BASH_BLOCKS=$(grep -c '```bash' "$COMMAND_FILE" || true)
if [ "$BASH_BLOCKS" -gt 0 ]; then
    echo "❌ FAIL: Command file contains $BASH_BLOCKS bash script blocks (expected 0)"
    exit 1
fi
echo "✓ Test 5: Command has no bash scripts"

# Test 6: Skill file exists
if [ ! -f "$SKILL_FILE" ]; then
    echo "❌ FAIL: review/SKILL.md not found"
    exit 1
fi
echo "✓ Test 6: Skill file exists"

# Test 7: Skill file contains execution logic (bash scripts)
SKILL_BASH_BLOCKS=$(grep -c '```bash' "$SKILL_FILE" || true)
if [ "$SKILL_BASH_BLOCKS" -eq 0 ]; then
    echo "❌ FAIL: Skill file has no bash scripts (execution logic missing)"
    exit 1
fi
echo "✓ Test 7: Skill contains $SKILL_BASH_BLOCKS bash script blocks"

# Test 8: Skill contains "Step 1" (execution steps)
if ! grep -q "Step 1" "$SKILL_FILE"; then
    echo "❌ FAIL: Skill file doesn't contain execution steps"
    exit 1
fi
echo "✓ Test 8: Skill contains execution steps"

echo ""
echo "=== All Tests PASS ✅ ==="
exit 0
