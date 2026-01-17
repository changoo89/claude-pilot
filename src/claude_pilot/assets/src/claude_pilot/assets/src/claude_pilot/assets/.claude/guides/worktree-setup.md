# Worktree Setup Guide

> **Purpose**: Complete worktree setup for isolated development environments
> **Usage**: `/02_execute --wt` flag enables worktree mode

## Overview

Worktree mode allows you to work on multiple branches simultaneously in isolated directories. Each worktree has its own working directory but shares the same Git object database.

## Why Use Worktrees?

- **Parallel Development**: Work on multiple features at once
- **Isolation**: Each branch in its own directory
- **Fast Switching**: No stash/commit needed to switch contexts
- **Safe**: Never lose uncommitted work when switching branches

## Worktree Mode Implementation

### Standard Mode (Default)

Single working directory, one active plan per branch.

```bash
# Standard mode setup (from 02_execute.md)
PROJECT_ROOT="${PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PLAN_PATH="${EXPLICIT_PATH}"

# Priority: Explicit path → Oldest pending → Most recent in_progress
[ -z "$PLAN_PATH" ] && PLAN_PATH="$(ls -1t "$PROJECT_ROOT/.pilot/plan/pending"/*.md 2>/dev/null | tail -1)"

# IF pending, MUST move FIRST
if [ -n "$PLAN_PATH" ] && printf "%s" "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH" || { echo "ERROR: Failed to move plan" >&2; exit 1; }
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

# Set active pointer
mkdir -p "$PROJECT_ROOT/.pilot/plan/active"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
printf "%s" "$PLAN_PATH" > "$PROJECT_ROOT/.pilot/plan/active/${KEY}.txt"
```

### Worktree Mode (--wt flag)

Isolated worktree directory with separate plan state management.

```bash
#!/bin/bash
# Worktree setup script (complete version)

set -o nounset
set -o pipefail

# Lock file management
LOCK_DIR="${PROJECT_ROOT}/.pilot/plan/locks"
LOCK_FILE="${LOCK_DIR}/worktree.lock"
WORKTREE_DIR="${PROJECT_ROOT}/.pilot/worktrees"
WORKTREE_ROOT="${WORKTREE_DIR}/${BRANCH}"

# Cleanup trap for error handling
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "ERROR: Worktree setup failed with exit code $exit_code" >&2
        # Remove any partial worktree state
        [ -d "${WORKTREE_ROOT}/.pilot/plan/active" ] && rm -rf "${WORKTREE_ROOT}/.pilot/plan/active"
        exit $exit_code
    fi
}

trap cleanup_on_error EXIT

# Create lock file directory
mkdir -p "$LOCK_DIR"

# Acquire lock (atomic operation)
exec 200>"$LOCK_FILE"
flock -n 200 || { echo "ERROR: Another worktree operation in progress" >&2; exit 1; }

# Detect current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")"
BRANCH_SAFE="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"

# Create worktree directory structure
mkdir -p "$WORKTREE_DIR"
mkdir -p "${WORKTREE_ROOT}/.pilot/plan/pending"
mkdir -p "${WORKTREE_ROOT}/.pilot/plan/in_progress"
mkdir -p "${WORKTREE_ROOT}/.pilot/plan/active"
mkdir -p "${WORKTREE_ROOT}/.pilot/plan/done"

# Dual active pointer setup:
# 1. Main repo active pointer (for cross-worktree reference)
printf "%s" "${WORKTREE_ROOT}/.pilot/plan/active/${BRANCH_SAFE}.txt" > \
    "${PROJECT_ROOT}/.pilot/plan/active/${BRANCH_SAFE}.txt"

# 2. Worktree-local active pointer (for worktree isolation)
printf "%s" "$PLAN_PATH" > \
    "${WORKTREE_ROOT}/.pilot/plan/active/${BRANCH_SAFE}.txt"

# Set environment variables for worktree mode
export PILOT_WORKTREE_MODE=1
export PILOT_WORKTREE_ROOT="$WORKTREE_ROOT"
export PILOT_WORKTREE_BRANCH="$BRANCH"

echo "Worktree mode initialized: $WORKTREE_ROOT"
echo "Branch: $BRANCH"
echo "Active plan pointer: ${WORKTREE_ROOT}/.pilot/plan/active/${BRANCH_SAFE}.txt"
```

## Component Functions

**Lock Management** (prevents concurrent operations):
```bash
acquire_lock() {
    local lock_file="$1" lock_fd=200
    eval "exec $lock_fd>\"$lock_file\""
    flock -n "$lock_fd" || { echo "ERROR: Lock held" >&2; return 1; }
    echo "$lock_fd" > "${lock_file}.fd"
}

release_lock() {
    local lock_fd_file="${1}.fd"
    [ -f "$lock_fd_file" ] && { eval "flock -u $(cat "$lock_fd_file") 2>/dev/null"; rm -f "$lock_fd_file"; }
}
```

**Dual Pointer Setup** (main repo + worktree-local):
```bash
setup_dual_pointers() {
    local project_root="$1" worktree_root="$2" branch="$3" plan_path="$4"
    local branch_safe="$(printf "%s" "$branch" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
    local main_pointer="${project_root}/.pilot/plan/active/${branch_safe}.txt"
    local local_pointer="${worktree_root}/.pilot/plan/active/${branch_safe}.txt"
    printf "%s" "$local_pointer" > "$main_pointer"
    printf "%s" "$plan_path" > "$local_pointer"
}
```

**Error Trapping** (cleans up partial state on failure):
```bash
cleanup_on_error() {
    [ $? -ne 0 ] && {
        echo "ERROR: Worktree setup failed" >&2
        [ -n "${MAIN_POINTER:-}" ] && rm -f "$MAIN_POINTER"
        [ -n "${LOCAL_POINTER:-}" ] && rm -f "$LOCAL_POINTER"
        [ -n "${LOCK_FILE:-}" ] && release_lock "$LOCK_FILE"
        exit $?
    }
}
trap cleanup_on_error EXIT
```

## Worktree Workflow

### Create Worktree
```bash
git worktree add ../feature-branch feature-branch
cd ../feature-branch
```

### Initialize Plan in Worktree
```bash
# Run /00_plan to create plan
# Run /02_execute --wt to initialize worktree mode
```

### Switch Between Worktrees
```bash
cd ../main-branch      # Switch to main branch worktree
cd ../feature-branch   # Switch to feature branch worktree
```

### Cleanup Worktree
```bash
git worktree remove ../feature-branch
```

## Worktree Best Practices

- **One Plan Per Worktree**: Each worktree tracks its own active plan
- **Lock Management**: Always acquire lock before plan operations
- **Error Handling**: Use traps to cleanup partial state
- **Pointer Validation**: Verify both pointers before accessing plan

## Troubleshooting

### Lock File Stuck
```bash
# Remove stale lock file
rm -f .pilot/plan/locks/worktree.lock
```

### Missing Active Pointer
```bash
# Re-create active pointer
PLAN_PATH="$(ls -1t .pilot/plan/in_progress/*.md | head -1)"
printf "%s" "$PLAN_PATH" > .pilot/plan/active/$(git rev-parse --abbrev-ref HEAD).txt
```

### Worktree State Conflicts
```bash
# Check active pointers
ls -la .pilot/plan/active/
cat .pilot/plan/active/*.txt

# Reset worktree state
rm -rf .pilot/plan/active/
mkdir -p .pilot/plan/active/
```

## Related Guides

- **Execution Command**: @.claude/commands/02_execute.md
- **Plan Management**: @.claude/guides/prp-framework.md
- **Git Workflow**: @.claude/skills/git-master/SKILL.md
