#!/bin/bash
# Test: Graceful fallback in /00_plan
# TS-3: Commands should gracefully fallback when Codex CLI is not installed

set -euo pipefail

# Test setup
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/../.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/.claude/commands"

echo "=== TS-3: Graceful Fallback Test ==="

# Commands to test
COMMANDS=("00_plan.md" "01_confirm.md" "91_document.md" "03_close.md" "999_publish.md")
ALL_PASS=true

for cmd in "${COMMANDS[@]}"; do
    CMD_FILE="$COMMANDS_DIR/$cmd"

    echo "Testing $cmd..."

    # Test: Check for graceful fallback pattern
    if grep -A3 "command -v codex" "$CMD_FILE" | grep -q "return 0"; then
        echo "✅ PASS: $cmd has graceful fallback"
    else
        echo "❌ FAIL: $cmd missing graceful fallback"
        ALL_PASS=false
    fi
done

echo ""

if [ "$ALL_PASS" = true ]; then
    echo "=== All tests PASSED for graceful fallback ==="
    exit 0
else
    echo "=== Some tests FAILED for graceful fallback ==="
    exit 1
fi
