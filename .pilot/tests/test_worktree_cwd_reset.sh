#!/usr/bin/env bash
#
# Test: Worktree Mode CWD Reset Issue
#
# Purpose: Demonstrate that Bash tool resets cwd after each call
# Expected: This test will FAIL until worktree mode is fixed
#

set -o nounset
set -o pipefail

echo "=== Test: Worktree Mode CWD Reset ==="
echo ""

# Create a temporary worktree for testing
TEST_DIR="$(mktemp -d)"
cd "$TEST_DIR"
echo "Initial directory: $TEST_DIR"
echo "After cd: $(pwd)"

# Simulate what happens in Claude Code Bash tool
echo ""
echo "Simulating Bash tool behavior:"
echo "  First call: cd to subdirectory"
mkdir subdir
cd subdir
echo "  pwd after cd: $(pwd)"

echo ""
echo "  Second call: pwd (cwd should reset)"
# In actual Claude Code, this would show the original directory
# For this test, we're still in the same shell
echo "  pwd: $(pwd)"

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo ""
echo "=== Test Complete ==="
echo ""
echo "NOTE: In Claude Code Bash tool, each call resets cwd."
echo "This test demonstrates the issue but doesn't fully replicate"
echo "the Claude Code behavior because we're in a single shell."
