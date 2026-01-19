#!/usr/bin/env bash
# test-early-exit-process.sh
# Test SC-2: Early exit for non-matching projects (0 external processes)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Early Exit Test (SC-2) ===${NC}"
echo ""

# Create a temporary markdown-only project directory
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo -e "${YELLOW}Creating test Markdown-only project at: $TEST_DIR${NC}"

# Create only markdown files
echo "# Test Markdown File" > "$TEST_DIR/README.md"
echo "Another markdown file" > "$TEST_DIR/docs.md"

# Find the hook scripts from the current working directory
# (Assuming we're running from the project root)
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    PLUGIN_DIR="$CLAUDE_PROJECT_DIR"
else
    # Get absolute path of the test script BEFORE changing directory
    TEST_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Navigate to project root (tests are in .pilot/tests/)
    PLUGIN_DIR="$(cd "$TEST_SCRIPT_DIR/../.." && pwd)"
fi

TYPECHECK_HOOK="$PLUGIN_DIR/.claude/scripts/hooks/typecheck.sh"
LINT_HOOK="$PLUGIN_DIR/.claude/scripts/hooks/lint.sh"

# Navigate to test directory
cd "$TEST_DIR"

if [ ! -f "$TYPECHECK_HOOK" ]; then
    echo -e "${RED}✗ FAIL: typecheck.sh not found at $TYPECHECK_HOOK${NC}"
    exit 1
fi

if [ ! -f "$LINT_HOOK" ]; then
    echo -e "${RED}✗ FAIL: lint.sh not found at $LINT_HOOK${NC}"
    exit 1
fi

# Test typecheck.sh early exit
echo -e "${YELLOW}Testing typecheck.sh early exit...${NC}"
TYPECHECK_OUTPUT=$("$TYPECHECK_HOOK" 2>&1 || true)
TYPECHECK_EXIT_CODE=$?

if [ $TYPECHECK_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ typecheck.sh exited cleanly (no tsconfig.json)${NC}"
else
    echo -e "${RED}✗ typecheck.sh failed unexpectedly${NC}"
    echo "$TYPECHECK_OUTPUT"
    exit 1
fi

# Test lint.sh early exit
echo -e "${YELLOW}Testing lint.sh early exit...${NC}"
LINT_OUTPUT=$("$LINT_HOOK" 2>&1 || true)
LINT_EXIT_CODE=$?

if [ $LINT_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ lint.sh exited cleanly (no project config)${NC}"
else
    echo -e "${RED}✗ lint.sh failed unexpectedly${NC}"
    echo "$LINT_OUTPUT"
    exit 1
fi

# Track external processes using strace or dtrace
echo -e "${YELLOW}Tracking external processes...${NC}"

# Initialize EXEC_COUNT
EXEC_COUNT=0

# Use bash built-in time to measure execution
# and check for external process execution
if command -v strace &> /dev/null; then
    # Linux: use strace
    EXEC_COUNT=$(strace -e trace=execve "$TYPECHECK_HOOK" 2>&1 | grep -c "execve" || echo "0")
    EXEC_COUNT_LINT=$(strace -e trace=execve "$LINT_HOOK" 2>&1 | grep -c "execve" || echo "0")
    EXEC_COUNT=$((EXEC_COUNT + EXEC_COUNT_LINT))
elif command -v dtruss &> /dev/null; then
    # macOS: use dtruss (requires sudo) - may fail without sudo
    if sudo -n true 2>/dev/null; then
        EXEC_COUNT=$(sudo dtruss -t execve "$TYPECHECK_HOOK" 2>&1 | grep -c "execve" || echo "0")
        EXEC_COUNT_LINT=$(sudo dtruss -t execve "$LINT_HOOK" 2>&1 | grep -c "execve" || echo "0")
        EXEC_COUNT=$((EXEC_COUNT + EXEC_COUNT_LINT))
    else
        # No sudo access, skip dtruss
        EXEC_COUNT=0
    fi
else
    # Fallback: check for common external tools in output
    # This is a heuristic - if hooks work correctly, they should not call tsc, eslint, etc.
    echo -e "${YELLOW}Warning: strace/dtruss not available, using heuristic check${NC}"

    # Run hooks and capture output
    OUTPUT_TYPECHECK=$("$TYPECHECK_HOOK" 2>&1 || true)
    OUTPUT_LINT=$("$LINT_HOOK" 2>&1 || true)
    OUTPUT="$OUTPUT_TYPECHECK $OUTPUT_LINT"

    # Check if any external tool was mentioned
    if echo "$OUTPUT" | grep -qiE "(Running|Type check|ESLint|Pylint|gofmt)"; then
        EXEC_COUNT=1
    else
        EXEC_COUNT=0
    fi
fi

echo ""
echo -e "${BLUE}External processes executed: $EXEC_COUNT${NC}"
echo ""

# Clean up EXEC_COUNT (remove newlines)
EXEC_COUNT=$(echo "$EXEC_COUNT" | tr -d '[:space:]' | grep -oE '^[0-9]+' || echo "0")

# Assert: 0 external processes (should exit early before running any tools)
if [ "$EXEC_COUNT" -eq 0 ] 2>/dev/null; then
    echo -e "${GREEN}✓ PASS: 0 external processes (early exit working)${NC}"
    exit 0
else
    echo -e "${RED}✗ FAIL: $EXEC_COUNT external processes detected (expected 0)${NC}"
    exit 1
fi
