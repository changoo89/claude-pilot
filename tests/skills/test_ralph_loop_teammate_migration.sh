#!/usr/bin/env bash
# Test: SC-9a - Ralph Loop teammate context migration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SKILL_FILE="$PROJECT_ROOT/.claude/skills/ralph-loop/SKILL.md"
REFERENCE_FILE="$PROJECT_ROOT/.claude/skills/ralph-loop/REFERENCE.md"

echo "Testing SC-9a: Ralph Loop teammate context migration..."

# Test 1: No "subagent" references in SKILL.md
echo -n "Test 1: Verify no 'subagent' in SKILL.md... "
if grep -i "subagent" "$SKILL_FILE" > /dev/null 2>&1; then
    echo "FAIL"
    echo "  Found 'subagent' references:"
    grep -n -i "subagent" "$SKILL_FILE"
    exit 1
fi
echo "PASS"

# Test 2: "Teammates Only" header present
echo -n "Test 2: Verify 'Teammates Only' header... "
if ! grep -q "⚠️ Teammates Only" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing '⚠️ Teammates Only' header"
    exit 1
fi
echo "PASS"

# Test 3: Teammate terminology present
echo -n "Test 3: Verify teammate terminology... "
if ! grep -q "teammate" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing 'teammate' terminology"
    exit 1
fi
echo "PASS"

# Test 4: Team Lead terminology present (not orchestrator)
echo -n "Test 4: Verify 'Team Lead' terminology... "
if grep -i "main orchestrator" "$SKILL_FILE" > /dev/null 2>&1; then
    echo "FAIL"
    echo "  Found 'main orchestrator' - should be 'Team Lead'"
    grep -n -i "main orchestrator" "$SKILL_FILE"
    exit 1
fi
echo "PASS"

# Test 5: Message pattern for BLOCKED state
echo -n "Test 5: Verify Message pattern for blocked state... "
if ! grep -q "message.*lead\|Message.*lead" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing Message pattern for blocked state"
    exit 1
fi
echo "PASS"

# Test 6: TaskCompleted hook reference
echo -n "Test 6: Verify TaskCompleted hook reference... "
if ! grep -q "TaskCompleted" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing TaskCompleted hook reference"
    exit 1
fi
echo "PASS"

# Test 7: TeammateIdle hook reference
echo -n "Test 7: Verify TeammateIdle hook reference... "
if ! grep -q "TeammateIdle" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing TeammateIdle hook reference"
    exit 1
fi
echo "PASS"

# Test 8: REFERENCE.md updated (no subagent)
echo -n "Test 8: Verify no 'subagent' in REFERENCE.md... "
if grep -i "subagent" "$REFERENCE_FILE" > /dev/null 2>&1; then
    echo "FAIL"
    echo "  Found 'subagent' references in REFERENCE.md:"
    grep -n -i "subagent" "$REFERENCE_FILE"
    exit 1
fi
echo "PASS"

# Test 9: No <CODER_BLOCKED> marker (replaced with Message)
echo -n "Test 9: Verify <CODER_BLOCKED> removal... "
if grep -q "<CODER_BLOCKED>" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Found <CODER_BLOCKED> marker - should use Message instead"
    exit 1
fi
echo "PASS"

# Test 10: <CODER_COMPLETE> marker still present
echo -n "Test 10: Verify <CODER_COMPLETE> marker present... "
if ! grep -q "<CODER_COMPLETE>" "$SKILL_FILE"; then
    echo "FAIL"
    echo "  Missing <CODER_COMPLETE> marker"
    exit 1
fi
echo "PASS"

echo ""
echo "All tests passed! ✅"
exit 0
