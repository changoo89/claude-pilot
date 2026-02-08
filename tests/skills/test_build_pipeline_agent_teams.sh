#!/bin/bash
# SC-11: Build Pipeline Agent Teams Support Test
# Purpose: Validate build script includes hooks/, agent-teams/, preserves executable permissions
# Usage: bash tests/skills/test_build_pipeline_agent_teams.sh
# Exit: 0 if all pass, 1 if any fail

set -e
PASS=0
FAIL=0
BASE_DIR="/Users/chanho/claude-pilot"
TEST_DIST_DIR="$BASE_DIR/dist-test-sc11"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASS=$((PASS + 1))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAIL=$((FAIL + 1))
}

test_info() {
    echo -e "${YELLOW}INFO${NC}: $1"
}

# Setup: Clean test dist directory
cleanup() {
    rm -rf "$TEST_DIST_DIR"
}

trap cleanup EXIT

# Build marketplace tree for testing
test_info "Building marketplace tree to $TEST_DIST_DIR"
bash "$BASE_DIR/scripts/build-marketplace-tree.sh" "$TEST_DIST_DIR" || {
    test_fail "Build script execution failed"
    exit 1
}

# Test 1: hooks/ directory included in dist
test_hooks_directory_included() {
    test_info "Test 1: Checking hooks/ directory in dist"

    local hooks_dir="$TEST_DIST_DIR/plugins/claude-pilot/hooks"
    if [ -d "$hooks_dir" ]; then
        test_pass "hooks/ directory included in dist"
    else
        test_fail "hooks/ directory NOT included in dist"
    fi
}

# Test 2: Hook files included
test_hook_files_included() {
    test_info "Test 2: Checking hook files in dist"

    local verify_script="$TEST_DIST_DIR/plugins/claude-pilot/hooks/verify-task-completion.sh"
    local idle_script="$TEST_DIST_DIR/plugins/claude-pilot/hooks/teammate-idle-check.sh"
    local readme="$TEST_DIST_DIR/plugins/claude-pilot/hooks/README.md"

    if [ -f "$verify_script" ]; then
        test_pass "verify-task-completion.sh included in dist"
    else
        test_fail "verify-task-completion.sh NOT included in dist"
    fi

    if [ -f "$idle_script" ]; then
        test_pass "teammate-idle-check.sh included in dist"
    else
        test_fail "teammate-idle-check.sh NOT included in dist"
    fi

    if [ -f "$readme" ]; then
        test_pass "hooks/README.md included in dist"
    else
        test_fail "hooks/README.md NOT included in dist"
    fi
}

# Test 3: Hook files have executable permissions
test_hook_files_executable() {
    test_info "Test 3: Checking hook file executable permissions"

    local verify_script="$TEST_DIST_DIR/plugins/claude-pilot/hooks/verify-task-completion.sh"
    local idle_script="$TEST_DIST_DIR/plugins/claude-pilot/hooks/teammate-idle-check.sh"

    if [ -f "$verify_script" ] && [ -x "$verify_script" ]; then
        test_pass "verify-task-completion.sh is executable"
    else
        test_fail "verify-task-completion.sh is NOT executable"
    fi

    if [ -f "$idle_script" ] && [ -x "$idle_script" ]; then
        test_pass "teammate-idle-check.sh is executable"
    else
        test_fail "teammate-idle-check.sh is NOT executable"
    fi
}

# Test 4: agent-teams/ skill directory included
test_agent_teams_skill_included() {
    test_info "Test 4: Checking agent-teams/ skill in dist"

    local agent_teams_dir="$TEST_DIST_DIR/plugins/claude-pilot/skills/agent-teams"
    if [ -d "$agent_teams_dir" ]; then
        test_pass "skills/agent-teams/ directory included in dist"
    else
        test_fail "skills/agent-teams/ directory NOT included in dist"
    fi
}

# Test 5: agent-teams skill files included
test_agent_teams_files_included() {
    test_info "Test 5: Checking agent-teams skill files"

    local skill_file="$TEST_DIST_DIR/plugins/claude-pilot/skills/agent-teams/SKILL.md"
    local reference_file="$TEST_DIST_DIR/plugins/claude-pilot/skills/agent-teams/REFERENCE.md"

    if [ -f "$skill_file" ]; then
        test_pass "agent-teams/SKILL.md included in dist"
    else
        test_fail "agent-teams/SKILL.md NOT included in dist"
    fi

    if [ -f "$reference_file" ]; then
        test_pass "agent-teams/REFERENCE.md included in dist"
    else
        test_fail "agent-teams/REFERENCE.md NOT included in dist"
    fi
}

# Test 6: No UNPREFIXED subagent_type references remain
test_no_unprefixed_subagent_type_references() {
    test_info "Test 6: Checking no unprefixed subagent_type references"

    # Count unprefixed references (subagent_type: agent-name without claude-pilot: prefix)
    local unprefixed_count=$(grep -rE "subagent_type:\s+(coder|tester|validator|explorer|researcher|documenter|plan-reviewer|code-reviewer|frontend-engineer|backend-engineer|security-analyst|build-error-resolver|design-reviewer)([^:]|$)" "$TEST_DIST_DIR/plugins/claude-pilot/skills" 2>/dev/null | grep -v "claude-pilot:" | wc -l | tr -d ' ')

    if [ "$unprefixed_count" -eq 0 ]; then
        test_pass "No unprefixed subagent_type references (all properly prefixed)"
    else
        test_fail "Found $unprefixed_count unprefixed subagent_type references"
    fi
}

# Test 7: marketplace.json includes Agent Teams metadata (if applicable)
test_marketplace_json_valid() {
    test_info "Test 7: Checking marketplace.json validity"

    local marketplace_json="$TEST_DIST_DIR/.claude-plugin/marketplace.json"
    if [ -f "$marketplace_json" ]; then
        # Validate JSON syntax
        if jq empty "$marketplace_json" 2>/dev/null; then
            test_pass "marketplace.json is valid JSON"
        else
            test_fail "marketplace.json is INVALID JSON"
        fi
    else
        test_fail "marketplace.json NOT found"
    fi
}

# Run all tests
echo "=========================================="
echo "SC-11: Build Pipeline Agent Teams Support"
echo "=========================================="
echo ""

test_hooks_directory_included
echo ""

test_hook_files_included
echo ""

test_hook_files_executable
echo ""

test_agent_teams_skill_included
echo ""

test_agent_teams_files_included
echo ""

test_no_unprefixed_subagent_type_references
echo ""

test_marketplace_json_valid
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}PASS${NC}: $PASS"
echo -e "${RED}FAIL${NC}: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed.${NC}"
    exit 1
fi
