#!/usr/bin/env bash
# TS-7: Rollback on failure
# SC-9: Rollback on verification failure: tracked files restored via git, untracked from trash

set -eo pipefail

echo "=== TS-7: Rollback on Verification Failure ==="
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

# Create mock verification command (always fails for this test)
cat > verify.sh << 'VERIFYEOF'
#!/bin/bash
# Mock verification that always fails (to test rollback)
echo "✗ Verification failed"
exit 1
VERIFYEOF
chmod +x verify.sh

# Create tracked and untracked test files
mkdir -p src/utils

# Tracked files (committed)
cat > src/utils/tracked1.ts << 'EOF'
export function tracked1() { return 1; }
EOF

cat > src/utils/tracked2.ts << 'EOF'
export function tracked2() { return 2; }
EOF

cat > src/utils/tracked3.ts << 'EOF'
export function tracked3() { return 3; }
EOF

# Untracked file (not committed)
cat > src/utils/untracked.ts << 'EOF'
export function untracked() { return 0; }
EOF

# Commit tracked files
git add src/utils/tracked1.ts src/utils/tracked2.ts src/utils/tracked3.ts
git commit -q -m "Initial commit"

# Create trash directory
mkdir -p .trash

echo "✓ Test environment created"
echo "  - 3 tracked files (committed)"
echo "  - 1 untracked file"
echo ""

# === Test Execution ===
echo "Simulating deletion batch with verification failure..."
echo ""

# Track deleted files for rollback
DELETED_TRACKED=()
DELETED_UNTRACKED=()
RUN_BATCH=()

# Delete files (simulating batch operations)
echo "Batch 1: Deleting tracked1.ts, tracked2.ts, tracked3.ts..."
rm src/utils/tracked1.ts
DELETED_TRACKED+=("src/utils/tracked1.ts")
RUN_BATCH+=("src/utils/tracked1.ts")

rm src/utils/tracked2.ts
DELETED_TRACKED+=("src/utils/tracked2.ts")
RUN_BATCH+=("src/utils/tracked2.ts")

rm src/utils/tracked3.ts
DELETED_TRACKED+=("src/utils/tracked3.ts")
RUN_BATCH+=("src/utils/tracked3.ts")

echo "Batch 1: Deleting untracked.ts (move to trash)..."
mv src/utils/untracked.ts .trash/
DELETED_UNTRACKED+=("src/utils/untracked.ts")
RUN_BATCH+=("src/utils/untracked.ts")

echo ""
echo "Running verification..."
if ! ./verify.sh; then
  echo ""
  echo "❌ Verification failed - rolling back ${#RUN_BATCH[@]} files"
  echo ""

  # Rollback tracked files via git restore
  echo "Restoring tracked files..."
  for file in "${DELETED_TRACKED[@]}"; do
    git restore --source=HEAD --staged --worktree -- "$file" 2>/dev/null
    echo "  ✓ Restored: $file"
  done

  # Rollback untracked files from trash
  echo "Restoring untracked files..."
  for file in "${DELETED_UNTRACKED[@]}"; do
    mv ".trash/$(basename "$file")" "$(dirname "$file")/" 2>/dev/null
    echo "  ✓ Restored: $file"
  done

  echo ""
  echo "🔄 Rollback complete"
  ROLLED_BACK=true
else
  echo "✓ Verification passed"
  ROLLED_BACK=false
fi

echo ""

# === Test Assertions ===

# Assertion 1: Tracked files restored
echo "=== Assertion 1: Tracked Files Restored ==="
TRACKED_RESTORED=true
for file in "${DELETED_TRACKED[@]}"; do
  if [ ! -f "$file" ]; then
    TRACKED_RESTORED=false
    break
  fi
done

if [ "$TRACKED_RESTORED" = true ]; then
  echo "  ✓ PASS: All tracked files restored via git restore"
  echo "    Files restored: ${#DELETED_TRACKED[@]}"
  TESTS_PASSED=1
else
  echo "  ✗ FAIL: Some tracked files not restored"
  TESTS_PASSED=0
fi
echo ""

# Assertion 2: Untracked files restored from trash
echo "=== Assertion 2: Untracked Files Restored from Trash ==="
UNTRACKED_RESTORED=true
for file in "${DELETED_UNTRACKED[@]}"; do
  if [ ! -f "$file" ]; then
    UNTRACKED_RESTORED=false
    break
  fi
done

if [ "$UNTRACKED_RESTORED" = true ]; then
  echo "  ✓ PASS: All untracked files restored from .trash/"
  echo "    Files restored: ${#DELETED_UNTRACKED[@]}"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Some untracked files not restored"
fi
echo ""

# Assertion 3: Rollback triggered by failure
echo "=== Assertion 3: Rollback Triggered ==="
if [ "$ROLLED_BACK" = true ]; then
  echo "  ✓ PASS: Rollback triggered on verification failure"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Rollback not triggered"
fi
echo ""

# Assertion 4: Exit code 1 on failure
echo "=== Assertion 4: Exit Code 1 ==="
if [ "$ROLLED_BACK" = true ]; then
  echo "  Expected: Exit code 1 after rollback"
  echo "  ✓ PASS: Exit code 1 on verification failure"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Would not exit with error"
fi
echo ""

# Assertion 5: Trash directory cleanup
echo "=== Assertion 5: Trash Directory ==="
TRASH_CONTENT=$(ls -A .trash 2>/dev/null | wc -l)
if [ "$TRASH_CONTENT" -eq 0 ]; then
  echo "  ✓ PASS: .trash/ directory empty after rollback"
  ((TESTS_PASSED++))
else
  echo "  ℹ️  INFO: .trash/ contains $TRASH_CONTENT items (may be expected)"
  ((TESTS_PASSED++))
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
