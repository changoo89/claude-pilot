#!/bin/bash
# Simplified test suite for hook scripts

set -euo pipefail

HOOKS_DIR="/Users/chanho/claude-pilot/.claude/hooks"
PASS=0
FAIL=0

echo "Running hook script tests..."
echo

# Test 1: Syntax check - verify-task-completion.sh
if bash -n "$HOOKS_DIR/verify-task-completion.sh" 2>/dev/null; then
    echo "✓ verify-task-completion.sh syntax check"
    ((PASS++))
else
    echo "✗ verify-task-completion.sh syntax check"
    ((FAIL++))
fi

# Test 2: Executable check - verify-task-completion.sh
if [ -x "$HOOKS_DIR/verify-task-completion.sh" ]; then
    echo "✓ verify-task-completion.sh is executable"
    ((PASS++))
else
    echo "✗ verify-task-completion.sh is executable"
    ((FAIL++))
fi

# Test 3: Syntax check - teammate-idle-check.sh
if bash -n "$HOOKS_DIR/teammate-idle-check.sh" 2>/dev/null; then
    echo "✓ teammate-idle-check.sh syntax check"
    ((PASS++))
else
    echo "✗ teammate-idle-check.sh syntax check"
    ((FAIL++))
fi

# Test 4: Executable check - teammate-idle-check.sh
if [ -x "$HOOKS_DIR/teammate-idle-check.sh" ]; then
    echo "✓ teammate-idle-check.sh is executable"
    ((PASS++))
else
    echo "✗ teammate-idle-check.sh is executable"
    ((FAIL++))
fi

# Test 5: verify-task-completion.sh - all TODOs checked (should pass)
TEST_DIR=$(mktemp -d)
PLAN_FILE="$TEST_DIR/plan.md"
cat > "$PLAN_FILE" <<'EOF'
- [x] SC-1: Done
- [x] SC-2: Done
EOF

mkdir -p "$TEST_DIR/bin"
cat > "$TEST_DIR/bin/npm" <<'SCRIPT'
#!/bin/bash
echo "PASS"
exit 0
SCRIPT
chmod +x "$TEST_DIR/bin/npm"

cat > "$TEST_DIR/package.json" <<'EOF'
{"name":"test"}
EOF

if (cd "$TEST_DIR" && PATH="$TEST_DIR/bin:$PATH" PLAN_PATH="$PLAN_FILE" timeout 5 "$HOOKS_DIR/verify-task-completion.sh" >/dev/null 2>&1); then
    echo "✓ verify-task-completion.sh allows completion with all TODOs checked"
    ((PASS++))
else
    echo "✗ verify-task-completion.sh allows completion with all TODOs checked"
    ((FAIL++))
fi
rm -rf "$TEST_DIR"

# Test 6: verify-task-completion.sh - unchecked TODOs (should reject)
TEST_DIR=$(mktemp -d)
PLAN_FILE="$TEST_DIR/plan.md"
cat > "$PLAN_FILE" <<'EOF'
- [ ] SC-1: Incomplete
- [x] SC-2: Done
EOF

if (cd "$TEST_DIR" && PLAN_PATH="$PLAN_FILE" timeout 5 "$HOOKS_DIR/verify-task-completion.sh" >/dev/null 2>&1); then
    echo "✗ verify-task-completion.sh rejects unchecked TODOs"
    ((FAIL++))
else
    exit_code=$?
    if [ $exit_code -eq 2 ]; then
        echo "✓ verify-task-completion.sh rejects unchecked TODOs"
        ((PASS++))
    else
        echo "✗ verify-task-completion.sh rejects unchecked TODOs (wrong exit code: $exit_code)"
        ((FAIL++))
    fi
fi
rm -rf "$TEST_DIR"

# Test 7: teammate-idle-check.sh - work complete (should allow idle)
TEST_DIR=$(mktemp -d)
PLAN_FILE="$TEST_DIR/plan.md"
cat > "$PLAN_FILE" <<'EOF'
- [x] SC-1: Done
EOF

mkdir -p "$TEST_DIR/bin"
cat > "$TEST_DIR/bin/npm" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
chmod +x "$TEST_DIR/bin/npm"

cat > "$TEST_DIR/package.json" <<'EOF'
{"name":"test"}
EOF

if (cd "$TEST_DIR" && PATH="$TEST_DIR/bin:$PATH" PLAN_PATH="$PLAN_FILE" timeout 5 "$HOOKS_DIR/teammate-idle-check.sh" >/dev/null 2>&1); then
    echo "✓ teammate-idle-check.sh allows idle with complete work"
    ((PASS++))
else
    echo "✗ teammate-idle-check.sh allows idle with complete work"
    ((FAIL++))
fi
rm -rf "$TEST_DIR"

# Test 8: teammate-idle-check.sh - work incomplete (should reject idle)
TEST_DIR=$(mktemp -d)
PLAN_FILE="$TEST_DIR/plan.md"
cat > "$PLAN_FILE" <<'EOF'
- [ ] SC-1: Incomplete
EOF

if (cd "$TEST_DIR" && PLAN_PATH="$PLAN_FILE" timeout 5 "$HOOKS_DIR/teammate-idle-check.sh" >/dev/null 2>&1); then
    echo "✗ teammate-idle-check.sh rejects idle with incomplete work"
    ((FAIL++))
else
    exit_code=$?
    if [ $exit_code -eq 2 ]; then
        echo "✓ teammate-idle-check.sh rejects idle with incomplete work"
        ((PASS++))
    else
        echo "✗ teammate-idle-check.sh rejects idle with incomplete work (wrong exit code: $exit_code)"
        ((FAIL++))
    fi
fi
rm -rf "$TEST_DIR"

# Summary
echo
echo "============================================"
echo "Test Results: PASS: $PASS | FAIL: $FAIL"
echo "============================================"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
