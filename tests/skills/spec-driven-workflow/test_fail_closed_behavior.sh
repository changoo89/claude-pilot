#!/bin/bash
# Test: Fail-Closed Behavior in REFERENCE.md
# Purpose: Verify fail-closed enforcement is documented

set -e

REFERENCE_FILE="/Users/chanho/claude-pilot/.claude/skills/spec-driven-workflow/REFERENCE.md"

echo "Test: Fail-Closed Behavior Verification"
echo "========================================"

# Test 1: Check for exact phrase "FAIL with missing-evidence report"
echo -n "Test 1: Check for fail-closed phrase... "
if grep -q "FAIL with missing-evidence report" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing exact phrase 'FAIL with missing-evidence report'"
  exit 1
fi

# Test 2: Verify Fail-Closed Enforcement section exists
echo -n "Test 2: Check for Fail-Closed Enforcement section... "
if grep -q "## Fail-Closed Enforcement" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing '## Fail-Closed Enforcement' section"
  exit 1
fi

# Test 3: Verify missing evidence report format is defined
echo -n "Test 3: Check for missing evidence report format... "
if grep -q "missing evidence report" "$REFERENCE_FILE"; then
  echo "✓ PASS"
else
  echo "✗ FAIL - Missing evidence report format not defined"
  exit 1
fi

# Test 4: Count occurrences of "FAIL with missing-evidence report" (SC-4 requirement: ≥1)
echo -n "Test 4: Count fail-closed phrases... "
COUNT=$(grep -c "FAIL with missing-evidence report" "$REFERENCE_FILE" || echo 0)
if [ "$COUNT" -ge 1 ]; then
  echo "✓ PASS (found $COUNT occurrences, target: ≥1)"
else
  echo "✗ FAIL - Expected ≥1 occurrences, found $COUNT"
  exit 1
fi

echo ""
echo "All tests passed! ✓"
