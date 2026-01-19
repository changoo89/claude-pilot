#!/bin/bash
# Test SC-1: 00_plan does NOT create plan files

set -e

TEST_NAME="SC-1: 00_plan does NOT create plan files"
TEST_DIR=".claude-pilot/.pilot/plan"

echo "════════════════════════════════════════════════════════════"
echo "Test: $TEST_NAME"
echo "════════════════════════════════════════════════════════════"
echo ""

# Setup: Ensure test directories exist and are empty
echo "📁 Setting up test environment..."
mkdir -p "$TEST_DIR/draft"
mkdir -p "$TEST_DIR/pending"
mkdir -p "$TEST_DIR/in_progress"
mkdir -p "$TEST_DIR/done"

# Clear any existing .md files (except .gitkeep)
find "$TEST_DIR" -name "*.md" -type f ! -name ".gitkeep" -delete 2>/dev/null || true

# Count initial files
INITIAL_COUNT=$(find "$TEST_DIR" -name "*.md" -type f ! -name ".gitkeep" | wc -l | tr -d ' ')
echo "✓ Initial .md file count: $INITIAL_COUNT"
echo ""

# Verify 00_plan.md does NOT contain plan file creation instructions
echo "🔍 Verifying 00_plan.md does NOT contain plan file creation..."

# Check for removed Step 4
if grep -q "## Step 4: Generate Plan Document" .claude/commands/00_plan.md; then
    echo "❌ FAIL: Step 4 (Generate Plan Document) still exists"
    exit 1
fi
echo "✓ Step 4 (Generate Plan Document) removed"

# Check for no "Write to" instructions for plan files
if grep -q "Write to.*\.pilot/plan/pending" .claude/commands/00_plan.md; then
    echo "❌ FAIL: Plan file creation instructions still exist"
    exit 1
fi
echo "✓ No plan file creation instructions found"

# Check Success Criteria includes "NO plan file created"
if ! grep -q "NO plan file created" .claude/commands/00_plan.md; then
    echo "❌ FAIL: Success Criteria does not mention NO plan file creation"
    exit 1
fi
echo "✓ Success Criteria includes 'NO plan file created'"

# Check that Step 3 guides user to /01_confirm
if ! grep -q "Run /01_confirm" .claude/commands/00_plan.md; then
    echo "❌ FAIL: Step 3 does not guide user to /01_confirm"
    exit 1
fi
echo "✓ Step 3 guides user to run /01_confirm"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ PASS: $TEST_NAME"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  - Step 4 (Generate Plan Document) removed"
echo "  - No plan file creation instructions found"
echo "  - Success Criteria includes 'NO plan file created'"
echo "  - User guided to run /01_confirm for plan save"
echo ""
