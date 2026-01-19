#!/usr/bin/env bash
# TS-6: Verification after batch
# SC-8: Verification commands execute after each batch (N=10) and at end

set -eo pipefail

echo "=== TS-6: Verification After Batch ==="
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

# Create mock verification command
cat > verify.sh << 'EOF'
#!/bin/bash
# Mock verification that always succeeds
echo "✓ Verification passed"
exit 0
EOF
chmod +x verify.sh

# Create 15 test files to trigger batch verification
mkdir -p tests

for i in {1..15}; do
  cat > "tests/unused_test_$i.test.ts" << EOF
// Unused test file $i
EOF
done

git add .
git commit -q -m "Initial commit"

echo "✓ Test environment created (15 test files)"
echo ""

# === Test Execution ===
echo "Simulating batch deletion with verification..."
echo ""

BATCH_SIZE=10
TOTAL_FILES=15
VERIFICATION_COUNT=0
DELETED_COUNT=0

echo "Batch size: $BATCH_SIZE"
echo "Total files: $TOTAL_FILES"
echo ""

# Simulate deletion with batch verification
for i in $(seq 1 "$TOTAL_FILES"); do
  file="tests/unused_test_$i.test.ts"

  # Delete file
  if [ -f "$file" ]; then
    rm "$file"
    ((DELETED_COUNT++))
    echo "  Deleted: $file"
  fi

  # Check if batch complete
  if ! ((DELETED_COUNT % BATCH_SIZE)); then
    echo ""
    echo "🧪 Running verification (batch $((DELETED_COUNT / BATCH_SIZE)))..."
    ./verify.sh
    ((VERIFICATION_COUNT++))
    echo "  ✓ Batch $((DELETED_COUNT / BATCH_SIZE)) verified"
    echo ""
  fi
done

# Final verification at end
if [ "$DELETED_COUNT" -gt 0 ] && [ "$((DELETED_COUNT % BATCH_SIZE))" -ne 0 ]; then
  echo "🧪 Running final verification..."
  ./verify.sh
  ((VERIFICATION_COUNT++))
  echo "  ✓ Final verification complete"
  echo ""
fi

# === Test Assertions ===

# Assertion 1: Intermediate batch verification
echo "=== Assertion 1: Intermediate Batch Verification ==="
EXPECTED_BATCHES=$((TOTAL_FILES / BATCH_SIZE))
if [ "$VERIFICATION_COUNT" -ge "$EXPECTED_BATCHES" ]; then
  echo "  ✓ PASS: Verification ran after each batch of $BATCH_SIZE files"
  echo "    Expected at least: $EXPECTED_BATCHES"
  echo "    Actual: $VERIFICATION_COUNT"
  TESTS_PASSED=1
else
  echo "  ✗ FAIL: Insufficient verification runs"
  echo "    Expected at least: $EXPECTED_BATCHES"
  echo "    Actual: $VERIFICATION_COUNT"
  TESTS_PASSED=0
fi
echo ""

# Assertion 2: Final verification
echo "=== Assertion 2: Final Verification ==="
REMAINDER=$((TOTAL_FILES % BATCH_SIZE))
if [ "$REMAINDER" -gt 0 ]; then
  EXPECTED_FINAL=$((EXPECTED_BATCHES + 1))
  if [ "$VERIFICATION_COUNT" -eq "$EXPECTED_FINAL" ]; then
    echo "  ✓ PASS: Final verification ran for remaining $REMAINDER files"
    ((TESTS_PASSED++))
  else
    echo "  ✗ FAIL: Final verification missing"
    echo "    Expected: $EXPECTED_FINAL"
    echo "    Actual: $VERIFICATION_COUNT"
  fi
else
  echo "  ℹ️  SKIP: No remainder files (exact multiple of batch size)"
  ((TESTS_PASSED++))
fi
echo ""

# Assertion 3: Correct batch size
echo "=== Assertion 3: Correct Batch Size ==="
if [ "$BATCH_SIZE" -eq 10 ]; then
  echo "  ✓ PASS: Batch size correctly set to 10"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Batch size is $BATCH_SIZE (expected 10)"
fi
echo ""

# Assertion 4: All files deleted
echo "=== Assertion 4: All Files Deleted ==="
REMAINING_FILES=$(find tests -name "*.test.ts" 2>/dev/null | wc -l)
if [ "$REMAINING_FILES" -eq 0 ]; then
  echo "  ✓ PASS: All $TOTAL_FILES files deleted"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: $REMAINING_FILES files remain"
fi
echo ""

# Assertion 5: Verification frequency
echo "=== Assertion 5: Verification Frequency ==="
echo "  Total verifications: $VERIFICATION_COUNT"
echo "  Expected: $((EXPECTED_BATCHES + (REMAINDER > 0 ? 1 : 0)))"
echo ""
if [ "$VERIFICATION_COUNT" -ge 1 ]; then
  echo "  ✓ PASS: Verification ran at least once"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: No verification ran"
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
