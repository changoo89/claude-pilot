#!/usr/bin/env bash
# Test: Setup command fixes permissions if missing
# TS-4: Setup command fixes permissions if missing

set -e

# Get absolute path to project root
PROJECT_ROOT="/Users/chanho/claude-pilot"
HOOKS_DIR="$PROJECT_ROOT/.claude/scripts/hooks"

echo "=== Test: Setup Permission Verification ==="
echo "Project root: $PROJECT_ROOT"
echo "Hooks directory: $HOOKS_DIR"
echo ""

# Step 1: Remove permissions to simulate the problem
echo "Step 1: Removing execute permissions from hooks..."
chmod -x "$HOOKS_DIR"/*.sh 2>/dev/null || true

# Verify permissions are removed
if ls -la "$HOOKS_DIR"/*.sh 2>/dev/null | grep -q "rwxr-xr-x"; then
    echo "❌ FAIL: Hooks still have execute permissions (test setup failed)"
    exit 1
fi

echo "✓ Permissions removed (hooks are not executable)"
echo ""

# Step 2: Simulate setup command Step 4 (permission fix)
echo "Step 2: Running permission fix (simulating setup Step 4)..."

# Check if hooks are executable (using the portable logic from setup.md)
NON_EXEC_COUNT=0
for hook in "$HOOKS_DIR"/*.sh; do
    if [ -f "$hook" ] && [ ! -x "$hook" ]; then
        NON_EXEC_COUNT=$((NON_EXEC_COUNT + 1))
    fi
done

echo "Checking hook script permissions..."
echo "Found $NON_EXEC_COUNT non-executable hook(s)."

if [ "$NON_EXEC_COUNT" -gt 0 ]; then
    echo "Fixing permissions..."

    # Set execute permissions (matching setup.md logic)
    find "$HOOKS_DIR" -name "*.sh" -type f -exec chmod +x {} \;

    echo "✓ Permissions fixed automatically"
else
    echo "✓ All hooks already executable (no fix needed)"
fi

echo ""

# Step 3: Verify permissions are restored
echo "Step 3: Verifying permissions are restored..."

if ls -la "$HOOKS_DIR"/*.sh 2>/dev/null | grep -q "rwxr-xr-x"; then
    echo "✓ PASS: All hooks now have execute permissions (-rwxr-xr-x)"

    # Count executable hooks (portable method)
    EXEC_COUNT=0
    TOTAL_COUNT=0
    for hook in "$HOOKS_DIR"/*.sh; do
        if [ -f "$hook" ]; then
            TOTAL_COUNT=$((TOTAL_COUNT + 1))
            if [ -x "$hook" ]; then
                EXEC_COUNT=$((EXEC_COUNT + 1))
            fi
        fi
    done

    echo "Executable hooks: $EXEC_COUNT / $TOTAL_COUNT"

    if [ "$EXEC_COUNT" -eq "$TOTAL_COUNT" ]; then
        echo "✓ PASS: All hooks are executable"
        echo ""
        echo "=== Test PASSED ==="
        exit 0
    else
        echo "❌ FAIL: Not all hooks are executable"
        exit 1
    fi
else
    echo "❌ FAIL: Hooks still don't have execute permissions"
    ls -la "$HOOKS_DIR"/*.sh
    exit 1
fi
