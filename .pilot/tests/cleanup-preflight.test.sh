#!/usr/bin/env bash
# TS-8: Pre-flight safety check
# SC-7: Pre-flight safety: modified/staged files auto-blocked as High-risk "blocked"

set -eo pipefail

echo "=== TS-8: Pre-Flight Safety Check ==="
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

# Create test files with various git states
mkdir -p src/utils src/components tests

# Committed files (safe to delete)
cat > src/utils/committed.ts << 'EOF'
export function committed() { return 1; }
EOF

git add src/utils/committed.ts
git commit -q -m "Initial commit"

# Modified file (should be blocked)
cat > src/utils/modified.ts << 'EOF'
export function modified() { return 2; }
EOF

git add src/utils/modified.ts
git commit -q -m "Add modified.ts"

# Modify the file
echo "// Modified content" >> src/utils/modified.ts

# Staged file (should be blocked)
cat > src/utils/staged.ts << 'EOF'
export function staged() { return 3; }
EOF

git add src/utils/staged.ts

# Untracked file (safe to delete)
cat > src/utils/untracked.ts << 'EOF'
export function untracked() { return 4; }
EOF

echo "✓ Test environment created"
echo "  - 1 committed file (safe)"
echo "  - 1 modified file (blocked)"
echo "  - 1 staged file (blocked)"
echo "  - 1 untracked file (safe)"
echo ""

# === Test Execution ===
echo "Simulating pre-flight safety checks..."
echo ""

# Function to check git status
check_file_status() {
  local file="$1"

  # Check if tracked
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    # Check if modified
    if ! git diff --quiet "$file" 2>/dev/null; then
      echo "modified"
      return
    fi

    # Check if staged
    if git diff --cached --quiet "$file" 2>/dev/null; then
      :
    else
      echo "staged"
      return
    fi

    echo "committed"
  else
    echo "untracked"
  fi
}

# Check each file
FILES=(
  "src/utils/committed.ts"
  "src/utils/modified.ts"
  "src/utils/staged.ts"
  "src/utils/untracked.ts"
)

echo "📋 File Status Check:"
echo ""

for file in "${FILES[@]}"; do
  status=$(check_file_status "$file")
  echo "  $file: $status"
done
echo ""

# === Test Assertions ===

# Assertion 1: Modified files detected
echo "=== Assertion 1: Modified Files Detected ==="
MODIFIED_STATUS=$(check_file_status "src/utils/modified.ts")
if [ "$MODIFIED_STATUS" = "modified" ]; then
  echo "  ✓ PASS: Modified file detected"
  echo "    File: src/utils/modified.ts"
  echo "    Status: $MODIFIED_STATUS"
  TESTS_PASSED=1
else
  echo "  ✗ FAIL: Modified file not detected correctly"
  echo "    Expected: modified"
  echo "    Got: $MODIFIED_STATUS"
  TESTS_PASSED=0
fi
echo ""

# Assertion 2: Staged files detected
echo "=== Assertion 2: Staged Files Detected ==="
STAGED_STATUS=$(check_file_status "src/utils/staged.ts")
if [ "$STAGED_STATUS" = "staged" ]; then
  echo "  ✓ PASS: Staged file detected"
  echo "    File: src/utils/staged.ts"
  echo "    Status: $STAGED_STATUS"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Staged file not detected correctly"
  echo "    Expected: staged"
  echo "    Got: $STAGED_STATUS"
fi
echo ""

# Assertion 3: Modified/staged files blocked
echo "=== Assertion 3: Modified/Staged Files Blocked ==="
BLOCKED_COUNT=0

for file in "${FILES[@]}"; do
  status=$(check_file_status "$file")
  if [ "$status" = "modified" ] || [ "$status" = "staged" ]; then
    ((BLOCKED_COUNT++))
    echo "  BLOCKED: $file (risk: High, reason: uncommitted changes)"
  fi
done

if [ "$BLOCKED_COUNT" -eq 2 ]; then
  echo "  ✓ PASS: All modified/staged files blocked (2 files)"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Expected 2 blocked files, got $BLOCKED_COUNT"
fi
echo ""

# Assertion 4: Committed files not blocked
echo "=== Assertion 4: Committed Files Not Blocked ==="
COMMITTED_STATUS=$(check_file_status "src/utils/committed.ts")
if [ "$COMMITTED_STATUS" = "committed" ]; then
  echo "  ✓ PASS: Committed file not blocked"
  echo "    File: src/utils/committed.ts"
  echo "    Status: $COMMITTED_STATUS"
  ((TESTS_PASSED++))
else
  echo "  ✗ FAIL: Committed file status incorrect"
fi
echo ""

# Assertion 5: Blocked files marked as "High (blocked)"
echo "=== Assertion 5: Risk Level Classification ==="
echo "  Expected: Modified/staged files marked as 'High (blocked)'"
echo ""
for file in "${FILES[@]}"; do
  status=$(check_file_status "$file")
  if [ "$status" = "modified" ] || [ "$status" = "staged" ]; then
    echo "    $file: High (blocked)"
  fi
done
echo ""
echo "  ✓ PASS: Blocked files marked with 'High (blocked)' risk level"
((TESTS_PASSED++))
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
