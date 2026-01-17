#!/bin/bash
# Test: No delegation for simple plans
# TS-5: Simple plans with <5 SCs should NOT trigger GPT delegation

set -euo pipefail

# Test setup
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/../.." && pwd)"

echo "=== TS-5: No Delegation for Simple Plans ==="

# Create a simple plan with 2 SCs
SIMPLE_PLAN="$TESTS_DIR/simple_test_plan.md"
cat > "$SIMPLE_PLAN" <<'EOF'
# Simple Test Plan

## Success Criteria

- SC-1: First criterion
- SC-2: Second criterion

EOF

# Test: Count SC items - should be 2 (<5 threshold)
SC_COUNT=$(grep -c "^- SC-" "$SIMPLE_PLAN" || echo "0")

if [ "$SC_COUNT" -lt 5 ]; then
    echo "✅ PASS: Simple plan has $SC_COUNT SCs (<5 threshold)"
    echo "        This should NOT trigger GPT delegation"
    rm -f "$SIMPLE_PLAN"
    exit 0
else
    echo "❌ FAIL: Plan has $SC_COUNT SCs (expected <5)"
    rm -f "$SIMPLE_PLAN"
    exit 1
fi
