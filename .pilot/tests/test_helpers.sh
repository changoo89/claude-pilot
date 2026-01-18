#!/bin/bash
# Test helper functions for /03_close tests

# Setup mock git repository
setup_mock_repo() {
    local test_dir="$1"
    local has_remote="${2:-true}"

    mkdir -p "$test_dir"
    cd "$test_dir" || return 1

    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "test" > README.md
    git add README.md
    git commit -q -m "Initial commit"

    if [ "$has_remote" = "true" ]; then
        git init -q --bare ../remote.git
        git remote add origin ../remote.git
    fi

    cd - > /dev/null || return 1
}

# Cleanup mock repository
cleanup_mock_repo() {
    rm -rf "$1"
}

# Create mock plan file
create_mock_plan() {
    local plan_path="$1"
    local title="${2:-Test Plan}"

    mkdir -p "$(dirname "$plan_path")"

    cat > "$plan_path" << PLANEOF
# Plan: ${title}

> **Created**: 2026-01-18
> **Status**: In Progress

## Success Criteria

- [ ] **SC-1**: Test success criterion
PLANEOF
}

# Mock git push failure
mock_git_push_failure() {
    # Create a wrapper function that simulates push failure
    eval 'git() {
        if [ "$1" = "push" ]; then
            echo "fatal: could not read Username for '\''https://github.com'\'': terminal prompts disabled" >&2
            return 128
        else
            command git "$@"
        fi
    }'
    export -f git
}

# Restore normal git behavior
unmock_git_push() {
    unset -f git
}
