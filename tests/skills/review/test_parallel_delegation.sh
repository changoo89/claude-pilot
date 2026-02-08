#!/bin/bash
# Test: Review skill uses parallel-subagents pattern and documenter delegation

PROJECT_ROOT="/Users/chanho/claude-pilot"
SKILL_FILE="$PROJECT_ROOT/.claude/skills/review/SKILL.md"
REFERENCE_FILE="$PROJECT_ROOT/.claude/skills/review/REFERENCE.md"

# Test 1: SKILL.md references parallel-subagents
if ! grep -q "parallel-subagents" "$SKILL_FILE"; then
    echo "FAIL: SKILL.md does not reference parallel-subagents"
    exit 1
fi

# Test 2: SKILL.md Step 2 explicitly references the skill
if ! grep -q "@.claude/skills/parallel-subagents/SKILL.md" "$SKILL_FILE"; then
    echo "FAIL: SKILL.md Step 2 does not explicitly reference parallel-subagents skill"
    exit 1
fi

# Test 3: REFERENCE.md has parallel review Task patterns
if ! grep -q "Task: subagent_type: tester" "$REFERENCE_FILE"; then
    echo "FAIL: REFERENCE.md missing tester Task pattern"
    exit 1
fi

if ! grep -q "Task: subagent_type: validator" "$REFERENCE_FILE"; then
    echo "FAIL: REFERENCE.md missing validator Task pattern"
    exit 1
fi

if ! grep -q "Task: subagent_type: code-reviewer" "$REFERENCE_FILE"; then
    echo "FAIL: REFERENCE.md missing code-reviewer Task pattern"
    exit 1
fi

# Test 4: REFERENCE.md has documenter Task pattern for Step 4
if ! grep -q "Task: subagent_type: documenter" "$REFERENCE_FILE"; then
    echo "FAIL: REFERENCE.md missing documenter Task pattern"
    exit 1
fi

# Test 5: REFERENCE.md has Parallel Review Task Patterns section
if ! grep -q "Parallel Review Task Patterns" "$REFERENCE_FILE"; then
    echo "FAIL: REFERENCE.md missing Parallel Review Task Patterns section"
    exit 1
fi

echo "PASS: All review skill delegation patterns verified"
exit 0
