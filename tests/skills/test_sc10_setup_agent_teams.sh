#!/bin/bash
# Test suite for SC-10: Agent Teams setup integration
# Tests that setup.md and setup-workflow/SKILL.md include Agent Teams configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test counters
PASS=0
FAIL=0
SKIP=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test helper
assert_exit_code() {
    local expected=$1
    local actual=$2
    local test_name=$3

    if [ "$expected" -eq "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASS++)) || true
    else
        echo -e "${RED}✗${NC} $test_name (expected: $expected, got: $actual)"
        ((FAIL++)) || true
    fi
}

assert_grep_match() {
    local pattern=$1
    local file=$2
    local test_name=$3

    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASS++)) || true
    else
        echo -e "${RED}✗${NC} $test_name (pattern not found: $pattern in $file)"
        ((FAIL++)) || true
    fi
}

# Test: setup.md references AGENT_TEAMS
test_setup_command_agent_teams() {
    assert_grep_match "AGENT_TEAMS" "$PROJECT_ROOT/.claude/commands/setup.md" \
        "setup.md mentions AGENT_TEAMS"
}

# Test: setup-workflow/SKILL.md references AGENT_TEAMS
test_setup_workflow_agent_teams() {
    assert_grep_match "AGENT_TEAMS" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md mentions AGENT_TEAMS"
}

# Test: setup-workflow includes env var configuration
test_setup_workflow_env_var() {
    assert_grep_match "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md includes env var configuration"
}

# Test: setup-workflow includes hook registration guide
test_setup_workflow_hooks() {
    assert_grep_match "TaskCompleted" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md includes TaskCompleted hook"

    assert_grep_match "TeammateIdle" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md includes TeammateIdle hook"
}

# Test: setup-workflow includes settings.json example
test_setup_workflow_settings_json() {
    assert_grep_match "settings.json" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md mentions settings.json"
}

# Test: setup-workflow includes terminal compatibility note
test_setup_workflow_terminal_compat() {
    assert_grep_match "tmux\|iTerm2\|terminal" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md mentions terminal compatibility"
}

# Test: setup-workflow includes verify-task-completion.sh reference
test_setup_workflow_verify_completion() {
    assert_grep_match "verify-task-completion.sh" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md mentions verify-task-completion.sh"
}

# Test: setup-workflow includes teammate-idle-check.sh reference
test_setup_workflow_idle_check() {
    assert_grep_match "teammate-idle-check.sh" "$PROJECT_ROOT/.claude/skills/setup-workflow/SKILL.md" \
        "setup-workflow/SKILL.md mentions teammate-idle-check.sh"
}

# Run all tests
echo "Running SC-10 setup Agent Teams integration tests..."
echo

test_setup_command_agent_teams
test_setup_workflow_agent_teams
test_setup_workflow_env_var
test_setup_workflow_hooks
test_setup_workflow_settings_json
test_setup_workflow_terminal_compat
test_setup_workflow_verify_completion
test_setup_workflow_idle_check

# Summary
echo
echo "============================================"
echo "Test Results:"
echo -e "${GREEN}PASS: $PASS${NC} | ${RED}FAIL: $FAIL${NC} | ${YELLOW}SKIP: $SKIP${NC}"
echo "============================================"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0
