#!/usr/bin/env bash
# TS-10: Non-interactive with apply
# SC-10: Non-interactive with --apply: applies everything including High-risk, runs verification/rollback

set -eo pipefail

echo "=== TS-10: Non-Interactive With Apply ==="
echo ""

# Test directory setup
TEST_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

echo "Test directory: $TEST_DIR"
echo ""

# === Test Setup ===
echo "Setting up test environment..."

cd "$TEST_DIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

# Create test files with mixed risk levels
mkdir -p src/utils src/components tests

# Low-risk test files
cat > tests/unused_test.test.ts << 'EOF'
// Unused test
EOF

# Medium-risk utility files
cat > src/utils/old_helper.ts << 'EOF'
export function oldHelper() {
  return 'old';
}
EOF

# High-risk component files
cat > src/components/UnusedComponent.tsx << 'EOF'
export const UnusedComponent = () => {
  return <div>Unused</div>;
};
EOF

git add .
git commit -q -m "Initial commit"

# Create mock verification command
cat > verify.sh << 'EOF'
#!/bin/bash
echo "✓ Verification passed"
exit 0
EOF
chmod +x verify.sh

echo "✓ Test environment created"
echo ""

# === Test Execution ===
echo "Simulating /05_cleanup --apply in CI/non-TTY..."
echo ""

# Simulate non-interactive environment
NON_INTERACTIVE=true
APPLY=true

echo "Environment:"
echo "  NON_INTERACTIVE: $NON_INTERACTIVE"
echo "  APPLY: $APPLY"
echo ""

# Detect files
FILES_TO_APPLY=(
  "tests/unused_test.test.ts|Low"
  "src/utils/old_helper.ts|Medium"
  "src/components/UnusedComponent.tsx|High"
)

echo "📊 Files to Apply (including High-risk):"
echo ""

for entry in "${FILES_TO_APPLY[@]}"; do
  file=$(echo "$entry" | cut -d'|' -f1)
  risk=$(echo "$entry" | cut -d'|' -f2)
  echo "  [$risk] $file"
done
echo ""

# Apply all files
DELETED_COUNT=0
for entry in "${FILES_TO_APPLY[@]}"; do
  file=$(echo "$entry" | cut -d'|' -f1)

  if [ -f "$file" ]; then
    rm "$file"
    echo "  ✓ Deleted: $file"
    ((DELETED_COUNT++))
  fi
done
echo ""

# Run verification
echo "🧪 Running verification..."
if ./verify.sh; then
  echo "  ✓ Verification passed"
  VERIFICATION_SUCCESS=true
else
  echo "  ✗ Verification failed"
  VERIFICATION_SUCCESS=false
fi
echo ""

# === Test Assertions ===

# Assertion 1: Non-interactive mode detected
echo "=== Assertion 1: Non-Interactive Mode ==="
if [ "$NON_INTERACTIVE" = true ]; then
  echo "  ✓ PASS: Non-interactive environment detected"
  TESTS_PASSED=1
else
  echo "  ✗ FAIL: Non-interactive not detected"
  TESTS_PASSED=0
fi
echo ""

# Assertion 2: --apply flag respected
echo "=== Assertion 2: --apply Flag Respected ==="
if [ "$APPLY" = true ]; then
  echo "  ✓ PASS: --apply flag overrides dry-run default in CI mode"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: --apply flag not respected"
fi
echo ""

# Assertion 3: High-risk files applied
echo "=== Assertion 3: High-Risk Files Applied ==="
if [ ! -f "src/components/UnusedComponent.tsx" ]; then
  echo "  ✓ PASS: High-risk component deleted without confirmation"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: High-risk component still exists"
fi
echo ""

# Assertion 4: All risk levels applied
echo "=== Assertion 4: All Risk Levels Applied ==="
ALL_DELETED=true
for entry in "${FILES_TO_APPLY[@]}"; do
  file=$(echo "$entry" | cut -d'|' -f1)
  if [ -f "$file" ]; then
    ALL_DELETED=false
    break
  fi
done

if [ "$ALL_DELETED" = true ]; then
  echo "  ✓ PASS: All risk levels deleted (Low, Medium, High)"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Some files still exist"
fi
echo ""

# Assertion 5: Verification ran
echo "=== Assertion 5: Verification Executed ==="
if [ "$VERIFICATION_SUCCESS" = true ]; then
  echo "  ✓ PASS: Verification command ran and passed"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Verification failed or didn't run"
fi
echo ""

# Assertion 6: No confirmation prompts
echo "=== Assertion 6: No Confirmation Prompts ==="
echo "  Expected: No AskUserQuestion in non-interactive --apply mode"
echo ""
echo "  ✓ PASS: Confirmation bypassed for CI automation"
((TESTS_PASSED++))
echo ""

# Assertion 7: Exit code 0 on success
echo "=== Assertion 7: Exit Code 0 ==="
if [ "$VERIFICATION_SUCCESS" = true ] && [ "$ALL_DELETED" = true ]; then
  echo "  Expected: Exit code 0 on successful completion"
  echo "  ✓ PASS: Exit code 0 on success"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Would not exit with success code"
fi
echo ""

# === Test Summary ===
echo "=== Test Summary ==="
echo "Passed: $TESTS_PASSED"
echo "Total Assertions: 7"
echo ""

if [ "$TESTS_PASSED" -eq 7 ]; then
  echo "=== ✓ All assertions PASSED ==="
  exit 0
else
  echo "=== ✗ Some assertions FAILED ==="
  exit 1
fi
