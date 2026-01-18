#!/bin/bash
# Test for SC-2: /999_release --skip-gh default behavior

set -e

# Source test helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helpers.sh"

# Test setup
TEST_DIR=$(mktemp -d)
trap "cleanup_mock_repo $TEST_DIR" EXIT

echo "=== Test: /999_release --skip-gh default ==="
echo "Test directory: $TEST_DIR"

# Setup mock repository
setup_mock_repo "$TEST_DIR"
cd "$TEST_DIR" || exit 1

# Setup plugin files
mkdir -p .claude-plugin
echo '{"version": "4.1.7"}' > .claude-plugin/plugin.json

cat > .claude-plugin/marketplace.json << 'EOF'
{
  "metadata": {
    "description": "Test plugin",
    "version": "4.1.7",
    "pluginRoot": "./"
  },
  "plugins": [{
    "name": "test-plugin",
    "source": "./",
    "description": "Test",
    "category": "testing",
    "version": "4.1.7",
    "author": {
      "name": "Test",
      "email": "test@example.com"
    },
    "homepage": "https://github.com/test/test",
    "repository": "https://github.com/test/test",
    "license": "MIT",
    "keywords": ["test"]
  }]
}
EOF

mkdir -p .claude
echo "4.1.7" > .claude/.pilot-version

# Commit initial state
git add .claude-plugin .claude
git commit -q -m "Initial plugin setup"

# Test 1: Verify SKIP_GH defaults to true
echo ""
echo "Test 1: Verify SKIP_GH defaults to true (should skip GitHub release)"

COMMAND_PATH="/Users/chanho/claude-pilot/.claude/commands/999_release.md"
# Check the variable initialization line (not the flag handling)
if grep -q "^SKIP_GH=true" "$COMMAND_PATH" 2>/dev/null; then
    echo "✓ PASS: SKIP_GH default is true (variable initialization)"
    TEST1_PASS=0
else
    echo "✗ FAIL: SKIP_GH default is not true"
    echo "Expected: SKIP_GH=true (variable initialization)"
    echo "Found:"
    grep "^SKIP_GH=" "$COMMAND_PATH" || echo "  (not found)"
    TEST1_PASS=1
fi

# Test 2: Verify --create-gh flag exists
echo ""
echo "Test 2: Verify --create-gh flag exists"

if grep -q "\-\-create-gh" "$COMMAND_PATH" 2>/dev/null; then
    echo "✓ PASS: --create-gh flag exists"
    TEST2_PASS=0
else
    echo "✗ FAIL: --create-gh flag not found"
    TEST2_PASS=1
fi

# Test 3: Verify argument parsing handles --create-gh
echo ""
echo "Test 3: Verify --create-gh flag sets SKIP_GH=false"

if grep -q '\-\-create-gh).*SKIP_GH=false' "$COMMAND_PATH" 2>/dev/null; then
    echo "✓ PASS: --create-gh flag sets SKIP_GH=false"
    TEST3_PASS=0
else
    echo "✗ FAIL: --create-gh flag does not set SKIP_GH=false"
    TEST3_PASS=1
fi

# Test 4: Verify documentation mentions new behavior
echo ""
echo "Test 4: Verify documentation updated for CI/CD integration"

if grep -qiE "CI/CD.*GitHub Actions|GitHub Actions.*release|skip.*gh.*default" "$COMMAND_PATH" 2>/dev/null; then
    echo "✓ PASS: Documentation mentions CI/CD or new default behavior"
    TEST4_PASS=0
else
    echo "⚠ WARN: Documentation might not mention CI/CD integration"
    TEST4_PASS=0  # Warning, not failure
fi

# Summary
echo ""
echo "=== Test Summary ==="
TOTAL_TESTS=4
FAILED_TESTS=$((TEST1_PASS + TEST2_PASS + TEST3_PASS))

if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ $FAILED_TESTS test(s) failed"
    exit 1
fi
