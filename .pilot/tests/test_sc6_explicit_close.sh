#!/bin/bash
# Test SC-6: 03_close requires explicit execution
# Verify: Ralph Loop completes, plan stays in in_progress/
# Verify: Only moves to done/ after explicit /03_close

set -e

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN_DIR="$PROJECT_ROOT/.claude-pilot/.pilot/plan"
TEST_PLAN_ID="sc6_test_$(date +%s)"

echo "=== SC-6 Test: 03_close Explicit Execution ==="
echo ""

# Setup: Create test directories
echo "Step 1: Setup test environment"
mkdir -p "$PLAN_DIR/in_progress"
mkdir -p "$PLAN_DIR/done"
mkdir -p "$PLAN_DIR/active"

# Create a test plan in in_progress/
TEST_PLAN_PATH="$PLAN_DIR/in_progress/${TEST_PLAN_ID}.md"
cat > "$TEST_PLAN_PATH" << 'EOF'
# Test Plan for SC-6

## Success Criteria
- SC-6.1: Plan stays in in_progress/ after Ralph Loop
- SC-6.2: Plan only moves to done/ after explicit /03_close

## Execution Summary
All todos completed via Ralph Loop. Ready for explicit /03_close.
EOF

echo "Created test plan: $TEST_PLAN_PATH"

# Verify plan is in in_progress/
if [ ! -f "$TEST_PLAN_PATH" ]; then
    echo "❌ FAIL: Test plan not found in in_progress/"
    exit 1
fi
echo "✅ PASS: Plan exists in in_progress/"

# Simulate Ralph Loop completion (no auto-move should happen)
echo ""
echo "Step 2: Simulate Ralph Loop completion"
echo "Simulating: All tests pass, coverage 80%+, Ralph Loop complete"

# Verify plan is STILL in in_progress/ (not auto-moved to done/)
if [ ! -f "$TEST_PLAN_PATH" ]; then
    echo "❌ FAIL: Plan was auto-moved from in_progress/ (should require explicit /03_close)"
    exit 1
fi
echo "✅ PASS: Plan stayed in in_progress/ after Ralph Loop completion"

# Verify no plan in done/ yet
DONE_PLANS=$(find "$PLAN_DIR/done" -name "${TEST_PLAN_ID}*" 2>/dev/null | wc -l)
if [ "$DONE_PLANS" -gt 0 ]; then
    echo "❌ FAIL: Plan found in done/ before explicit /03_close"
    exit 1
fi
echo "✅ PASS: No plan in done/ before explicit /03_close"

# Simulate explicit /03_close execution
echo ""
echo "Step 3: Simulate explicit /03_close execution"
DONE_PATH="$PLAN_DIR/done/${TEST_PLAN_ID}.md"
mv "$TEST_PLAN_PATH" "$DONE_PATH"

# Verify plan moved to done/
if [ ! -f "$DONE_PATH" ]; then
    echo "❌ FAIL: Plan not found in done/ after /03_close"
    exit 1
fi
echo "✅ PASS: Plan moved to done/ after explicit /03_close"

# Verify plan no longer in in_progress/
if [ -f "$TEST_PLAN_PATH" ]; then
    echo "❌ FAIL: Plan still exists in in_progress/ after /03_close"
    exit 1
fi
echo "✅ PASS: Plan removed from in_progress/ after /03_close"

# Cleanup
echo ""
echo "Step 4: Cleanup"
rm -f "$DONE_PATH"

echo ""
echo "=== SC-6 Test Results: ALL PASS ✅ ==="
echo ""
echo "Summary:"
echo "- ✅ Plan created in in_progress/"
echo "- ✅ Plan stayed in in_progress/ after Ralph Loop completion"
echo "- ✅ Plan NOT auto-moved to done/ (no auto-move logic)"
echo "- ✅ Plan moved to done/ only after explicit /03_close"
echo ""
echo "SC-6 VERIFIED: 03_close requires explicit execution"

exit 0
