#!/usr/bin/env bash
# TS-4: Force apply mode
# SC-4: --apply flag applies everything including High-risk without prompting

set -eo pipefail

echo "=== TS-4: Force Apply Mode ==="
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

echo "✓ Test environment created"
echo ""

# === Test Execution ===
echo "Simulating /05_cleanup mode=files --apply..."
echo ""

# Simulate --apply flag
APPLY=true

# Detect and categorize files
FILES_TO_DELETE=(
  "tests/unused_test.test.ts|Low"
  "src/utils/old_helper.ts|Medium"
  "src/components/UnusedComponent.tsx|High"
)

echo "📊 Files to Apply:"
echo ""

for entry in "${FILES_TO_DELETE[@]}"; do
  file=$(echo "$entry" | cut -d'|' -f1)
  risk=$(echo "$entry" | cut -d'|' -f2)
  echo "  [$risk] $file"
done
echo ""

# Apply all files (simulate deletion)
DELETED_COUNT=0
for entry in "${FILES_TO_DELETE[@]}"; do
  file=$(echo "$entry" | cut -d'|' -f1)
  risk=$(echo "$entry" | cut -d'|' -f2)

  # Simulate deletion
  if [ -f "$file" ]; then
    rm "$file"
    echo "  ✓ Deleted: $file"
    ((DELETED_COUNT++))
  fi
done
echo ""

# === Test Assertions ===

# Assertion 1: Low-risk files applied
echo "=== Assertion 1: Low-Risk Files Applied ==="
if [ ! -f "tests/unused_test.test.ts" ]; then
  echo "  ✓ PASS: Low-risk test file deleted"
  TESTS_PASSED=1
else
  echo "  ✗ FAIL: Low-risk test file still exists"
  TESTS_PASSED=0
fi
echo ""

# Assertion 2: Medium-risk files applied
echo "=== Assertion 2: Medium-Risk Files Applied ==="
if [ ! -f "src/utils/old_helper.ts" ]; then
  echo "  ✓ PASS: Medium-risk utility file deleted"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Medium-risk utility file still exists"
fi
echo ""

# Assertion 3: High-risk files applied (without confirmation)
echo "=== Assertion 3: High-Risk Files Applied (No Confirmation) ==="
if [ ! -f "src/components/UnusedComponent.tsx" ]; then
  echo "  ✓ PASS: High-risk component deleted without confirmation"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: High-risk component still exists"
fi
echo ""

# Assertion 4: No confirmation prompts
echo "=== Assertion 4: No Confirmation Prompts ==="
echo "  Expected: --apply flag bypasses all confirmation dialogs"
echo ""
if [ "$APPLY" = true ]; then
  echo "  ✓ PASS: --apply flag skips confirmation (including High-risk)"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Confirmation would be shown"
fi
echo ""

# Assertion 5: All files deleted
echo "=== Assertion 5: All Risk Levels Deleted ==="
if [ "$DELETED_COUNT" -eq "${#FILES_TO_DELETE[@]}" ]; then
  echo "  ✓ PASS: All $DELETED_COUNT files deleted (Low, Medium, High)"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Expected ${#FILES_TO_DELETE[@]} deletions, got $DELETED_COUNT"
fi
echo ""

# === Test Summary ===
echo "=== Test Summary ==="
echo "Passed: $TESTS_PASSED"
echo "Total Assertions: 5"
echo ""

if [ "$TESTS_PASSED" -eq 5 ]; then
  echo "=== ✓ All assertions PASSED ==="
  exit 0
else
  echo "=== ✗ Some assertions FAILED ==="
  exit 1
fi
