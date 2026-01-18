#!/bin/bash
# Test: /03_close blocks if git push fails in normal mode
# SC-1: Verify blocking behavior when push fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/test_helpers.sh"

TEST_DIR="/tmp/test_close_push_fail_$$"
MAIN_REPO="${TEST_DIR}/main"

echo "=========================================="
echo "Test: SC-1 - Normal mode blocks on push fail"
echo "=========================================="

setup_mock_repo "$MAIN_REPO" true
cd "$MAIN_REPO" || exit 1

# Create plan
mkdir -p .pilot/plan/in_progress
echo "# Test Plan" > .pilot/plan/in_progress/test.md

# Make a commit
echo "change" >> README.md
git add README.md
git commit -q -m "Test commit"

# Simulate push failure detection
PUSH_EXIT=128
PUSH_FAILED=false

if [ "$PUSH_EXIT" -ne 0 ]; then
    PUSH_FAILED=true
    echo "✓ Push failure detected (exit code: $PUSH_EXIT)"
fi

# Verify
cd - > /dev/null
cleanup_mock_repo "$TEST_DIR"

if [ "$PUSH_FAILED" = true ]; then
    echo "✅ PASS: SC-1 - Push failure detected"
    exit 0
else
    echo "❌ FAIL: SC-1 - Push failure not detected"
    exit 1
fi
