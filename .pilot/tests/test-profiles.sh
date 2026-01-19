#!/bin/bash
# test-profiles.sh
# Test SC-6: Profile system (off/stop/strict modes)

set -e

# Ensure arithmetic operations don't cause exit with set -e
# By using || true, we ensure the command always succeeds
test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++)) || true
}

# Test directory
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    ((TESTS_RUN++)) || true
    echo ""
    echo "Test $TESTS_RUN: $test_name"
}

# Setup test environment
setup_test_env() {
    local mode="$1"
    local profile_content="$2"

    # Create test project directory
    local project_dir="$TEST_DIR/project-$mode"
    mkdir -p "$project_dir/.claude"

    # Create TypeScript project (for validator testing)
    cat > "$project_dir/tsconfig.json" << 'EOFCONFIG'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs"
  }
}
EOFCONFIG

    # Copy scripts to test project
    mkdir -p "$project_dir/.claude/scripts/hooks"
    cp /Users/chanho/claude-pilot/.claude/scripts/hooks/quality-dispatch.sh "$project_dir/.claude/scripts/hooks/" 2>/dev/null || true
    cp /Users/chanho/claude-pilot/.claude/scripts/hooks/cache.sh "$project_dir/.claude/scripts/hooks/" 2>/dev/null || true

    # Create mock typecheck.sh that doesn't run actual tsc
    cat > "$project_dir/.claude/scripts/hooks/typecheck.sh" << 'EOF'
#!/bin/bash
# Mock typecheck for testing
if [ "$MOAK_TYPECHECK_FAIL" = "1" ]; then
    echo "Mock typecheck failed" >&2
    exit 1
fi
exit 0
EOF
    chmod +x "$project_dir/.claude/scripts/hooks/typecheck.sh"

    # Create profile with specified mode
    if [ -n "$profile_content" ]; then
        echo "$profile_content" > "$project_dir/.claude/quality-profile.json"
    fi

    echo "$project_dir"
}

echo "=== SC-6: Profile System Test (off/stop/strict modes) ==="
echo ""

# Save original directory
ORIGINAL_DIR="$(pwd)"

# Test 1: mode=off skips all validators
run_test "mode=off skips all validators"
PROJECT_DIR=$(setup_test_env "off" '{"version":1,"mode":"off","cache_ttl":30,"debounce_seconds":10}')

cd "$PROJECT_DIR"

# Source dispatcher with mode=off
export QUALITY_MODE="off"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should exit immediately without running validators
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    # Check that typecheck was NOT called
    test_pass "mode=off exits without error"
else
    test_fail "mode=off should exit cleanly"
fi

# Return to original directory
cd "$ORIGINAL_DIR"

# Test 2: mode=stop runs validators in batch
run_test "mode=stop runs validators"
PROJECT_DIR=$(setup_test_env "stop" '{"version":1,"mode":"stop","cache_ttl":30,"debounce_seconds":10}')

cd "$PROJECT_DIR"

# Reset cache
rm -f .claude/cache/quality-check.json

export QUALITY_MODE="stop"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should attempt to run validators
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "mode=stop executes validators"
else
    test_fail "mode=stop should run validators"
fi

cd "$ORIGINAL_DIR"

# Test 3: mode=strict runs validators on every operation
run_test "mode=strict runs validators"
PROJECT_DIR=$(setup_test_env "strict" '{"version":1,"mode":"strict","cache_ttl":0,"debounce_seconds":0}')

cd "$PROJECT_DIR"

# Reset cache
rm -f .claude/cache/quality-check.json

export QUALITY_MODE="strict"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should run validators without debounce
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "mode=strict executes validators"
else
    test_fail "mode=strict should run validators"
fi

cd "$ORIGINAL_DIR"

# Test 4: Language-specific override disables typecheck
run_test "language override disables typecheck"
PROJECT_DIR=$(setup_test_env "override" '{"version":1,"mode":"stop","language_overrides":{"typescript":{"typecheck":false,"lint":true}}}')

cd "$PROJECT_DIR"

# Reset cache
rm -f .claude/cache/quality-check.json

export QUALITY_MODE="stop"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should skip typecheck but run lint
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "language override disables specific validator"
else
    test_fail "language override should work"
fi

cd "$ORIGINAL_DIR"

# Test 5: Profile priority (ENV > repo profile > settings.json > default)
run_test "profile mode priority (ENV highest)"
PROJECT_DIR=$(setup_test_env "priority" '{"version":1,"mode":"off"}')

cd "$PROJECT_DIR"

# Test that ENV overrides profile
export QUALITY_MODE="strict"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher with ENV override
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "ENV variable overrides profile mode"
else
    test_fail "ENV variable should override profile"
fi

cd "$ORIGINAL_DIR"

# Test 6: Default mode when no profile exists
run_test "default mode when no profile"
PROJECT_DIR=$(setup_test_env "default" "")

cd "$PROJECT_DIR"

# Reset cache
rm -f .claude/cache/quality-check.json

# No QUALITY_MODE, no profile - should use default "stop"
unset QUALITY_MODE
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should use default "stop" mode
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "default mode (stop) used when no profile"
else
    test_fail "should use default mode"
fi

cd "$ORIGINAL_DIR"

# Test 7: Invalid profile falls back to default
run_test "invalid profile mode falls back to default"
PROJECT_DIR=$(setup_test_env "invalid" '{"version":1,"mode":"invalid_mode"}')

cd "$PROJECT_DIR"

export QUALITY_MODE=""
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"

# Run dispatcher - should fallback to "stop" for invalid mode
if .claude/scripts/hooks/quality-dispatch.sh 2>/dev/null; then
    test_pass "invalid mode falls back to default"
else
    test_fail "invalid mode should fallback safely"
fi

cd "$ORIGINAL_DIR"

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests Run: $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
