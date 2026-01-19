#!/bin/bash
# Test SC-2: 01_confirm saves to .claude-pilot/.pilot/plan/draft/ first

set -e

PROJECT_ROOT="/Users/chanho/claude-pilot"
DRAFT_DIR="$PROJECT_ROOT/.claude-pilot/.pilot/plan/draft"
PENDING_DIR="$PROJECT_ROOT/.claude-pilot/.pilot/plan/pending"

echo "=== Test SC-2: 01_confirm saves to draft/ first ==="
echo ""

# Cleanup function
cleanup() {
    rm -f "$DRAFT_DIR"/*_test_plan.md 2>/dev/null || true
    rm -f "$PENDING_DIR"/*_test_plan.md 2>/dev/null || true
}
trap cleanup EXIT

# Test 1: Verify draft directory exists
echo "Test 1: Verify draft directory exists"
if [ -d "$DRAFT_DIR" ]; then
    echo "✓ PASS: Draft directory exists at $DRAFT_DIR"
else
    echo "✗ FAIL: Draft directory does not exist"
    exit 1
fi
echo ""

# Test 2: Verify 01_confirm.md contains correct path
echo "Test 2: Verify 01_confirm.md contains correct draft/ path"
if grep -q 'PLAN_FILE="$PROJECT_ROOT/.claude-pilot/.pilot/plan/draft/' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✓ PASS: 01_confirm.md saves to draft/ folder"
else
    echo "✗ FAIL: 01_confirm.md does not save to draft/ folder"
    exit 1
fi
echo ""

# Test 3: Verify 01_confirm.md does NOT save directly to pending/
echo "Test 3: Verify 01_confirm.md does NOT save directly to pending/"
if grep -q 'PLAN_FILE="$PROJECT_ROOT/.claude-pilot/.pilot/plan/pending/' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✗ FAIL: 01_confirm.md still saves directly to pending/ folder"
    exit 1
else
    echo "✓ PASS: 01_confirm.md does not save directly to pending/"
fi
echo ""

# Test 4: Verify Success Criteria mentions draft/
echo "Test 4: Verify Success Criteria mentions draft/"
if grep -q 'Plan file created in `.claude-pilot/.pilot/plan/draft/`' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✓ PASS: Success Criteria mentions draft/ folder"
else
    echo "✗ FAIL: Success Criteria does not mention draft/ folder"
    exit 1
fi
echo ""

# Test 5: Verify STOP section mentions draft/
echo "Test 5: Verify STOP section mentions draft/"
if grep -q 'Plan created in `.claude-pilot/.pilot/plan/draft/`' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✓ PASS: STOP section mentions draft/ folder"
else
    echo "✗ FAIL: STOP section does not mention draft/ folder"
    exit 1
fi
echo ""

# Test 6: Verify description mentions draft/
echo "Test 6: Verify command description mentions draft/"
if grep -q 'create file in draft/' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✓ PASS: Command description mentions draft/ folder"
else
    echo "✗ FAIL: Command description does not mention draft/ folder"
    exit 1
fi
echo ""

# Test 7: Verify mkdir creates draft/ directory
echo "Test 7: Verify mkdir creates draft/ directory"
if grep -q 'mkdir -p "$PROJECT_ROOT/.claude-pilot/.pilot/plan/draft"' "$PROJECT_ROOT/.claude/commands/01_confirm.md"; then
    echo "✓ PASS: mkdir command creates draft/ directory"
else
    echo "✗ FAIL: mkdir command does not create draft/ directory"
    exit 1
fi
echo ""

echo "=== All SC-2 Tests Passed (7/7) ==="
echo ""
echo "Summary:"
echo "- Draft directory exists at .claude-pilot/.pilot/plan/draft/"
echo "- 01_confirm.md saves to draft/ folder (not pending/)"
echo "- All references updated to .claude-pilot/.pilot/plan/draft/"
echo "- Success Criteria, STOP section, and description updated"
echo "- mkdir command creates draft/ directory"
