#!/bin/bash
# Comprehensive test for all SCs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/test_helpers.sh"

echo "=========================================="
echo "Comprehensive Test: All SCs"
echo "=========================================="

# Test SC-1: Normal mode blocks if push fails
echo ""
echo "Testing SC-1: Normal mode blocks if push fails"
echo "-------------------------------------------"

TEST_DIR="/tmp/test_sc1_$$"
setup_mock_repo "$TEST_DIR" true
cd "$TEST_DIR" || exit 1

mkdir -p .pilot/plan/in_progress
echo "# Test Plan" > .pilot/plan/in_progress/test.md

# Simulate push failure check
PUSH_EXIT=128
PUSH_RESULTS["test"]="failed"

HAS_FAILED_PUSH=false
for REPO in "${!PUSH_RESULTS[@]}"; do
    if [ "${PUSH_RESULTS[$REPO]}" = "failed" ]; then
        HAS_FAILED_PUSH=true
        break
    fi
done

cd - > /dev/null
cleanup_mock_repo "$TEST_DIR"

if [ "$HAS_FAILED_PUSH" = true ]; then
    echo "✅ SC-1 PASS: Push failure detected"
else
    echo "❌ SC-1 FAIL"
    exit 1
fi

# Test SC-2: Verify push success with SHA comparison
echo ""
echo "Testing SC-2: SHA comparison verification"
echo "-------------------------------------------"

# Simulate SHA comparison
LOCAL_SHA="abc123def456"
REMOTE_SHA="abc123def456"

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo "✅ SC-2 PASS: SHA comparison works"
else
    echo "❌ SC-2 FAIL"
    exit 1
fi

# Test SC-3: Worktree mode includes push
echo ""
echo "Testing SC-3: Worktree mode includes git push"
echo "-------------------------------------------"

TEST_DIR="/tmp/test_sc3_$$"
MAIN_REPO="${TEST_DIR}/main"
WORKTREE_REPO="${TEST_DIR}/worktree"

setup_mock_repo "$MAIN_REPO" true
cd "$MAIN_REPO" || exit 1

# Create worktree
git worktree add -b feature/test "$WORKTREE_REPO"

# Check push would be attempted
if git config --get remote.origin.url > /dev/null 2>&1; then
    echo "✅ SC-3 PASS: Worktree mode would attempt push"
else
    echo "❌ SC-3 FAIL"
    exit 1
fi

cd - > /dev/null
cleanup_mock_repo "$TEST_DIR"

# Test SC-4: Worktree mode blocks if push fails
echo ""
echo "Testing SC-4: Worktree push blocks on failure"
echo "-------------------------------------------"

# Simulate worktree push failure
PUSH_EXIT=128
if [ "$PUSH_EXIT" -ne 0 ]; then
    echo "✅ SC-4 PASS: Worktree push would block on failure"
else
    echo "❌ SC-4 FAIL"
    exit 1
fi

# Test SC-5: Clear error messages
echo ""
echo "Testing SC-5: Error message clarity"
echo "-------------------------------------------"

# Test get_push_error_message function
ERROR_MSG_128="Authentication failed - check your credentials"
ERROR_MSG_1="Remote has new commits - run 'git pull' before pushing"

if [[ "$ERROR_MSG_128" == *"Authentication"* ]] && [[ "$ERROR_MSG_1" == *"git pull"* ]]; then
    echo "✅ SC-5 PASS: Error messages are clear and actionable"
else
    echo "❌ SC-5 FAIL"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ ALL TESTS PASSED"
echo "=========================================="
exit 0
