#!/usr/bin/env bash
# Test: SC-1 - Add 5+ SCs GPT delegation trigger to /01_confirm.md
# Verify: Step 2.5 exists with SC_COUNT check

set -euo pipefail

PROJECT_ROOT="/Users/chanho/claude-pilot"
TARGET_FILE="$PROJECT_ROOT/.claude/commands/01_confirm.md"

echo "Test: SC-1 - GPT Delegation Trigger in /01_confirm.md"
echo "======================================================"

# Test 1: Step 2.5 section exists
echo -n "Test 1: Check Step 2.5 section exists... "
if grep -q "## Step 2.5:" "$TARGET_FILE"; then
  echo "PASS"
else
  echo "FAIL"
  exit 1
fi

# Test 2: SC_COUNT variable check exists in Step 2.5
echo -n "Test 2: Check SC_COUNT in Step 2.5 block... "
SC_COUNT_CHECK=$(grep -A10 "## Step 2.5:" "$TARGET_FILE" | grep -c "SC_COUNT" || echo 0)
if [ "$SC_COUNT_CHECK" -ge 1 ]; then
  echo "PASS (found $SC_COUNT_CHECK occurrence)"
else
  echo "FAIL (expected >= 1, got $SC_COUNT_CHECK)"
  exit 1
fi

# Test 3: Graceful fallback pattern exists
echo -n "Test 3: Check graceful fallback pattern... "
if grep -A10 "## Step 2.5:" "$TARGET_FILE" | grep -q "command -v codex"; then
  echo "PASS"
else
  echo "FAIL"
  exit 1
fi

# Test 4: File size under 200 lines
echo -n "Test 4: Check file size under 200 lines... "
LINE_COUNT=$(wc -l < "$TARGET_FILE")
if [ "$LINE_COUNT" -le 200 ]; then
  echo "PASS ($LINE_COUNT lines)"
else
  echo "FAIL ($LINE_COUNT lines, expected <= 200)"
  exit 1
fi

echo ""
echo "All tests PASSED"
exit 0
