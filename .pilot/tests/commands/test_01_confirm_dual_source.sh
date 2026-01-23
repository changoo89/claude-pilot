#!/bin/bash
# Test: /01_confirm dual-source extraction (SC-2 and SC-3)

set -e

CONFIRM_FILE="/Users/chanho/claude-pilot/.claude/commands/01_confirm.md"

if [ ! -f "$CONFIRM_FILE" ]; then
    echo "✗ File not found: $CONFIRM_FILE"
    exit 1
fi

CONTENT=$(cat "$CONFIRM_FILE")

PASSED=0
FAILED=0

# Helper function
check() {
    local pattern="$1"
    local description="$2"

    if echo "$CONTENT" | grep -q "$pattern"; then
        echo "✓ $description"
        ((PASSED++)) || true
    else
        echo "✗ $description (looking for: $pattern)"
        ((FAILED++)) || true
    fi
}

echo "=== Testing /01_confirm Dual-Source Extraction ==="
echo ""

# SC-2: Dual-source extraction
echo "=== SC-2: Dual-Source Extraction ==="
check "Step 1: Dual-Source Extraction" "SC-2.1: Step 1 renamed to 'Dual-Source Extraction'"
check "Step 1.1: Load Draft File" "SC-2.2: Has Step 1.1 for loading draft"
check ".pilot/plan/draft" "SC-2.3a: Mentions draft directory"
check "draft.md" "SC-2.3b: Mentions draft.md files"
check "Step 1.2: Scan Conversation" "SC-2.4: Has Step 1.2 for scanning conversation"
check "LLM scan" "SC-2.5: Mentions LLM scans conversation"
check "UR-1, UR-2" "SC-2.6: Extracts User Requirements with IDs"
echo ""

# SC-3: Cross-check
echo "=== SC-3: Cross-Check and Omission Resolution ==="
check "Step 1.3: Cross-Check" "SC-3.1: Has Step 1.3 for cross-checking"
check "Compare draft vs conversation" "SC-3.2: Compares draft with conversation"
check "Flag MISSING items" "SC-3.3: Flags MISSING items in cross-check"
check "MISSING" "SC-3.4: Identifies MISSING items"
check "Step 1.4: Resolve Omissions" "SC-3.5: Has Step 1.4 for resolving omissions"
check "AskUserQuestion" "SC-3.6: Uses AskUserQuestion for resolution"
check "multiSelect: true" "SC-3.7: Uses multiSelect for confirmation"
echo ""

# Summary
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
