#!/bin/bash
# Test: Agent Teams skill file structure and content

set -e

SKILL_FILE="/Users/chanho/claude-pilot/.claude/skills/agent-teams/SKILL.md"
REFERENCE_FILE="/Users/chanho/claude-pilot/.claude/skills/agent-teams/REFERENCE.md"

echo "Testing Agent Teams skill files..."

# Test 1: Files exist
echo "Test 1: Verify files exist"
test -f "$SKILL_FILE" || { echo "FAIL: SKILL.md not found"; exit 1; }
test -f "$REFERENCE_FILE" || { echo "FAIL: REFERENCE.md not found"; exit 1; }
echo "PASS: Both files exist"

# Test 2: SKILL.md has frontmatter with correct name
echo "Test 2: Verify SKILL.md frontmatter"
grep -q "^name: agent-teams$" "$SKILL_FILE" || { echo "FAIL: Missing or incorrect name in frontmatter"; exit 1; }
grep -q "^description:" "$SKILL_FILE" || { echo "FAIL: Missing description in frontmatter"; exit 1; }
echo "PASS: Frontmatter correct"

# Test 3: SKILL.md contains all 3 team templates
echo "Test 3: Verify 3 team templates present"
TEMPLATE_COUNT=$(grep -c "execution-team\|review-team\|planning-team" "$SKILL_FILE")
if [ "$TEMPLATE_COUNT" -lt 3 ]; then
    echo "FAIL: Expected at least 3 team template references, found $TEMPLATE_COUNT"
    exit 1
fi
echo "PASS: All 3 team templates found"

# Test 4: SKILL.md file size (≤200 lines per vibe-coding)
echo "Test 4: Verify SKILL.md line count (≤200 lines)"
LINE_COUNT=$(wc -l < "$SKILL_FILE")
if [ "$LINE_COUNT" -gt 200 ]; then
    echo "FAIL: SKILL.md has $LINE_COUNT lines (max 200)"
    exit 1
fi
echo "PASS: SKILL.md has $LINE_COUNT lines (≤200)"

# Test 5: Core principles present
echo "Test 5: Verify core principles"
grep -qi "delegate mode" "$SKILL_FILE" || { echo "FAIL: Missing 'delegate mode' principle"; exit 1; }
grep -qi "teammate" "$SKILL_FILE" || { echo "FAIL: Missing 'teammate' references"; exit 1; }
grep -qi "TaskCompleted" "$SKILL_FILE" || { echo "FAIL: Missing 'TaskCompleted' hook reference"; exit 1; }
echo "PASS: Core principles found"

# Test 6: REFERENCE.md has detailed content
echo "Test 6: Verify REFERENCE.md has detailed content"
REF_LINE_COUNT=$(wc -l < "$REFERENCE_FILE")
if [ "$REF_LINE_COUNT" -lt 50 ]; then
    echo "FAIL: REFERENCE.md too short ($REF_LINE_COUNT lines)"
    exit 1
fi
echo "PASS: REFERENCE.md has adequate detail ($REF_LINE_COUNT lines)"

# Test 7: settings.json example present
echo "Test 7: Verify settings.json hook registration example"
grep -qi "settings.json" "$REFERENCE_FILE" || { echo "FAIL: Missing settings.json example"; exit 1; }
echo "PASS: settings.json example found"

echo ""
echo "All tests passed! ✅"
