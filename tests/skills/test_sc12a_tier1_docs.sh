#!/bin/bash
# Test: SC-12a Tier 1 Documentation Update
# Purpose: Verify Agent Teams content added to all 3 Tier 1 docs

set -e

CLAUDE_MD="/Users/chanho/claude-pilot/CLAUDE.md"
PROJECT_STRUCTURE="/Users/chanho/claude-pilot/docs/ai-context/project-structure.md"
DOCS_OVERVIEW="/Users/chanho/claude-pilot/docs/ai-context/docs-overview.md"

echo "=== SC-12a: Tier 1 Documentation Tests ==="
echo ""

# Test 1: Agent Teams mentioned in all 3 files
echo "Test 1: Checking 'Agent Teams' presence in all files..."
if ! grep -q "Agent Teams" "$CLAUDE_MD"; then
  echo "❌ FAIL: 'Agent Teams' not found in CLAUDE.md"
  exit 1
fi

if ! grep -q "Agent Teams" "$PROJECT_STRUCTURE"; then
  echo "❌ FAIL: 'Agent Teams' not found in project-structure.md"
  exit 1
fi

if ! grep -q "Agent Teams" "$DOCS_OVERVIEW"; then
  echo "❌ FAIL: 'Agent Teams' not found in docs-overview.md"
  exit 1
fi
echo "✅ PASS: 'Agent Teams' found in all 3 files"
echo ""

# Test 2: CLAUDE.md line count ≤ 200
echo "Test 2: Checking CLAUDE.md line count..."
LINE_COUNT=$(wc -l < "$CLAUDE_MD" | tr -d ' ')
if [ "$LINE_COUNT" -gt 200 ]; then
  echo "❌ FAIL: CLAUDE.md has $LINE_COUNT lines (limit: 200)"
  exit 1
fi
echo "✅ PASS: CLAUDE.md has $LINE_COUNT lines (limit: 200)"
echo ""

# Test 3: project-structure.md contains hooks directory
echo "Test 3: Checking hooks/ directory in project-structure.md..."
if ! grep -q "hooks/" "$PROJECT_STRUCTURE"; then
  echo "❌ FAIL: 'hooks/' not found in project-structure.md"
  exit 1
fi
echo "✅ PASS: 'hooks/' found in project-structure.md"
echo ""

# Test 4: docs-overview.md contains agent-teams skill
echo "Test 4: Checking agent-teams in docs-overview.md..."
if ! grep -q "agent-teams" "$DOCS_OVERVIEW"; then
  echo "❌ FAIL: 'agent-teams' not found in docs-overview.md"
  exit 1
fi
echo "✅ PASS: 'agent-teams' found in docs-overview.md"
echo ""

echo "=== All Tests Passed ✅ ==="
exit 0
