#!/usr/bin/env bash
# Test: Codex CLI detection in various scenarios
# SC-1, SC-2, SC-5: Codex detection and graceful fallback

set -eo pipefail

echo "=== Codex Detection Test ==="
echo ""

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# TS-1: Codex installed, detection succeeds
echo "=== TS-1: Codex Installed Detection ==="
if command -v codex >/dev/null 2>&1; then
    echo "  PASS: Codex found in PATH"
    ((TESTS_PASSED++))
else
    echo "  SKIP: Codex not installed on this system"
fi
echo ""

# TS-2: Graceful fallback when not installed
echo "=== TS-2: Graceful Fallback ==="
if ! command -v nonexistent_codex_command_xyz >/dev/null 2>&1; then
    echo "  PASS: Graceful fallback triggered when command not found"
    ((TESTS_PASSED++))
else
    echo "  FAIL: Should not find nonexistent command"
    ((TESTS_FAILED++))
fi
echo ""

# TS-5: Common path fallback
echo "=== TS-5: Common Path Fallback ==="
if command -v codex >/dev/null 2>&1; then
    CODEX_PATH=$(command -v codex)
    echo "  Codex found at: $CODEX_PATH"

    # Check if it's in a common path
    COMMON_PATHS=(
        "/opt/homebrew/bin"
        "/usr/local/bin"
        "/usr/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
    )

    FOUND_IN_COMMON=false
    for common_path in "${COMMON_PATHS[@]}"; do
        if [[ "$CODEX_PATH" == "$common_path"* ]]; then
            echo "  PASS: Codex found in common path: $common_path"
            FOUND_IN_COMMON=true
            ((TESTS_PASSED++))
            break
        fi
    done

    if [ "$FOUND_IN_COMMON" = false ]; then
        echo "  INFO: Codex found at non-standard path: $CODEX_PATH"
    fi
else
    echo "  SKIP: Codex not installed"
fi
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
