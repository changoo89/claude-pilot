#!/usr/bin/env bash
#
# test_verify_push.sh
#
# Test SC-2: Verify push success before marking complete
# Tests that push verification compares local/remote SHA
#

set -eo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_skip() {
    echo -e "${YELLOW}⊘ SKIP${NC}: $1"
}

# Setup test environment
setup_test_repo() {
    local test_dir="$1"
    local has_remote="${2:-true}"

    # Create test repo
    mkdir -p "$test_dir"
    cd "$test_dir"
    git init

    # Configure user
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "test" > README.md
    git add README.md
    git commit -m "Initial commit"

    # Create mock remote (bare repo) if requested
    if [ "$has_remote" = "true" ]; then
        git init --bare ../remote.git
        git remote add origin ../remote.git
    fi

    cd -
}

cleanup_test_repo() {
    local test_dir="$1"
    rm -rf "$test_dir"
}

# Main test
echo "Testing SC-2: Verify push success by comparing SHA..."
echo ""

# Create temporary test directory
TEST_TMP_DIR="$(mktemp -d)"
trap "cleanup_test_repo '$TEST_TMP_DIR'" EXIT

# Test 1: Push verification logic exists in /03_close.md Step 7.4
echo "Test 1: Checking if push verification is documented in Step 7.4..."
if grep -A 30 "### 7.4 Verify" .claude/commands/03_close.md | grep -q "SHA"; then
    test_pass "Push verification with SHA comparison found in Step 7.4"
else
    test_fail "Push verification not found in Step 7.4"
fi

# Test 2: SHA comparison logic exists
echo ""
echo "Test 2: Checking if SHA comparison logic is documented..."
if grep -q "rev-parse.*origin" .claude/commands/03_close.md 2>/dev/null; then
    test_pass "SHA comparison logic found in /03_close.md"
else
    test_fail "SHA comparison logic not found in /03_close.md"
fi

# Test 3: Verify Step 7.4 checks push success
echo ""
echo "Test 3: Checking if Step 7.4 verifies push success..."
if grep -A 20 "### 7.4 Verify" .claude/commands/03_close.md | grep -q "success"; then
    test_pass "Step 7.4 checks for push success"
else
    test_fail "Step 7.4 does not verify push success"
fi

# Test 4: Integration test - mock scenario
echo ""
echo "Test 4: Integration test with mock repository..."
setup_test_repo "$TEST_TMP_DIR/test-repo" "true"

cd "$TEST_TMP_DIR/test-repo"

# Create a commit
echo "change" >> README.md
git add README.md
git commit -m "Test commit"

# Get local SHA
LOCAL_SHA="$(git rev-parse HEAD)"

# Push to remote
git push origin main >/dev/null 2>&1 || {
    test_fail "Failed to push in test setup"
    cd /
    exit 1
}

# Get remote SHA
REMOTE_SHA="$(git rev-parse origin/main)"

# Compare SHAs
if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    test_pass "Local and remote SHA match after successful push"
else
    test_fail "Local SHA ($LOCAL_SHA) != Remote SHA ($REMOTE_SHA)"
fi

cd /

# Summary
echo ""
echo "═══════════════════════════════════════"
echo "Test Summary:"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo "═══════════════════════════════════════"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
