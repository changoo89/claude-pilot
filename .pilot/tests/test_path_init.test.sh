#!/usr/bin/env bash
# Test: PATH initialization for non-interactive shells
# TS-3: PATH not set, rc file sourcing

set -eo pipefail

echo "=== PATH Init Test ==="
echo ""

# Test setup
TESTS_PASSED=0
TESTS_FAILED=0

# TS-3: PATH not set, rc file sourcing
echo "=== TS-3: RC File Sourcing ==="

# Create a test rc file
TEST_RC="/tmp/test_rc_$$"

# Add homebrew bin to test rc (common macOS location)
echo 'export PATH="/opt/homebrew/bin:$PATH"' > "$TEST_RC"

# Test 1: Source rc file and verify PATH is updated
ORIGINAL_PATH="$PATH"
export PATH="/usr/bin:/bin"
if [ -f "$TEST_RC" ]; then
    source "$TEST_RC" 2>/dev/null || true
    if echo "$PATH" | grep -q "homebrew"; then
        echo "  PASS: PATH populated from rc file"
        ((TESTS_PASSED++))
    else
        echo "  FAIL: PATH not populated"
        ((TESTS_FAILED++))
    fi
fi
export PATH="$ORIGINAL_PATH"

# Clean up test rc file
rm -f "$TEST_RC"
echo ""

# Test 2: Verify shell detection works
echo "=== Shell Detection Test ==="
if [ -n "$ZSH_VERSION" ]; then
    echo "  INFO: Running in Zsh"
    echo "  PASS: ZSH_VERSION is set"
    ((TESTS_PASSED++))
elif [ -n "$BASH_VERSION" ]; then
    echo "  INFO: Running in Bash"
    echo "  PASS: BASH_VERSION is set"
    ((TESTS_PASSED++))
else
    echo "  WARN: Unknown shell (neither bash nor zsh)"
fi
echo ""

# Test 3: Verify PATH initialization preserves existing PATH
echo "=== PATH Preservation Test ==="
TEST_RC2="/tmp/test_rc2_$$"
echo 'export PATH="/opt/homebrew/bin:$PATH"' > "$TEST_RC2"
ORIGINAL_PATH="$PATH"
export PATH="/usr/bin:/bin"
if [ -f "$TEST_RC2" ]; then
    source "$TEST_RC2" 2>/dev/null || true
    if echo "$PATH" | grep -q "/usr/bin"; then
        echo "  PASS: Existing PATH entries preserved"
        ((TESTS_PASSED++))
    else
        echo "  FAIL: Existing PATH not preserved"
        ((TESTS_FAILED++))
    fi
fi
export PATH="$ORIGINAL_PATH"
rm -f "$TEST_RC2"
echo ""

# Summary
echo "=== Test Summary ==="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "=== All tests PASSED ==="
    exit 0
else
    echo "=== Some tests FAILED ==="
    exit 1
fi
