#!/bin/bash
set -e

echo "=== Test: Validation Checklist for SC-3 ==="
echo "Checking: Context engineering guidelines in orchestration.md"

FILE="/Users/chanho/claude-pilot/.claude/rules/delegator/orchestration.md"

# Check 1: Phase Context Determination section exists
if grep -q "Step 3.5: Determine Phase Context" "$FILE"; then
  echo "✅ PASS: Phase Context Determination section exists"
else
  echo "❌ FAIL: Phase Context Determination section missing"
  exit 1
fi

# Check 2: Phase Detection table exists
if grep -q "|.*Planning.*|.*Keywords.*|" "$FILE"; then
  echo "✅ PASS: Phase Detection table exists"
else
  echo "❌ FAIL: Phase Detection table missing"
  exit 1
fi

# Check 3: Decision Rule documented
if grep -q "Decision Rule" "$FILE"; then
  echo "✅ PASS: Decision Rule documented"
else
  echo "❌ FAIL: Decision Rule not documented"
  exit 1
fi

# Check 4: Anti-Patterns section exists
if grep -q "Anti-Patterns" "$FILE"; then
  echo "✅ PASS: Anti-Patterns section exists"
else
  echo "❌ FAIL: Anti-Patterns section missing"
  exit 1
fi

# Check 5: Context Engineering section exists
if grep -q "## Context Engineering for Delegation" "$FILE"; then
  echo "✅ PASS: Context Engineering section exists"
else
  echo "❌ FAIL: Context Engineering section missing"
  exit 1
fi

# Check 6: Dynamic Context Components documented
if grep -q "Dynamic Components" "$FILE"; then
  echo "✅ PASS: Dynamic Context Components documented"
else
  echo "❌ FAIL: Dynamic Context Components not documented"
  exit 1
fi

# Check 7: Context Selection Strategy exists
if grep -q "Context Selection Strategy" "$FILE"; then
  echo "✅ PASS: Context Selection Strategy documented"
else
  echo "❌ FAIL: Context Selection Strategy missing"
  exit 1
fi

# Check 8: Phase Detection in context strategy
if grep -q "1. Phase Detection" "$FILE"; then
  echo "✅ PASS: Phase Detection strategy documented"
else
  echo "❌ FAIL: Phase Detection strategy missing"
  exit 1
fi

# Check 9: History Injection documented
if grep -q "2. History Injection" "$FILE"; then
  echo "✅ PASS: History Injection strategy documented"
else
  echo "❌ FAIL: History Injection strategy missing"
  exit 1
fi

# Check 10: Token Budget Awareness documented
if grep -q "4. Token Budget Awareness" "$FILE"; then
  echo "✅ PASS: Token Budget Awareness documented"
else
  echo "❌ FAIL: Token Budget Awareness missing"
  exit 1
fi

# Check 11: Enhanced Step 5 with iteration count
if grep -q "5. \*\*Iteration count\*\* (if multiple attempts)" "$FILE"; then
  echo "✅ PASS: Step 5 enhanced with iteration count"
else
  echo "❌ FAIL: Step 5 not enhanced with iteration count"
  exit 1
fi

# Check 12: Context Template provided
if grep -q "### Context Template" "$FILE"; then
  echo "✅ PASS: Context Template provided"
else
  echo "❌ FAIL: Context Template missing"
  exit 1
fi

echo ""
echo "=== All 12 Validation Checks Passed ==="
echo "SC-3: Context engineering guidelines integrated successfully"
exit 0
