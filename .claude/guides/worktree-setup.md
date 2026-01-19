# Worktree Setup Guide

> **Purpose**: Complete worktree setup for isolated development environments
> **Full Reference**: @.claude/guides/worktree-setup-REFERENCE.md
> **Usage**: `/02_execute --wt` flag

---

## Overview

Worktree mode allows parallel branch work in isolated directories, sharing the same Git object database.

**Benefits**:
- **Parallel Development**: Multiple features at once
- **Isolation**: Each branch in separate directory
- **Fast Switching**: No stash/commit needed
- **Safe**: Never lose uncommitted work

---

## Worktree Modes

### Standard Mode (Default)

Single working directory, one active plan per branch.

**Full script**: @.claude/guides/worktree-setup-REFERENCE.md#standard-mode-default

### Worktree Mode (--wt flag)

Isolated worktree with separate plan state management.

**Key features**:
- Atomic lock mechanism (prevents race conditions)
- Dual active pointers (main repo + worktree-local)
- Environment variables for mode detection
- Error trap for cleanup

**Full script**: @.claude/guides/worktree-setup-REFERENCE.md#worktree-mode---wt-flag

---

## Component Functions

### Lock Management

Prevents concurrent operations:

```bash
acquire_lock() {
    local lock_file="$1" lock_fd=200
    eval "exec $lock_fd>\"$lock_file\""
    flock -n "$lock_fd" || { echo "ERROR: Lock held" >&2; return 1; }
}

release_lock() {
    local lock_fd_file="${1}.fd"
    [ -f "$lock_fd_file" ] && { eval "flock -u $(cat "$lock_fd_file") 2>/dev/null"; rm -f "$lock_fd_file"; }
}
```

### Dual Pointer Setup

Main repo + worktree-local pointers for cross-worktree reference.

**Full details**: @.claude/guides/worktree-setup-REFERENCE.md#dual-pointer-setup-main-repo--worktree-local

### Error Trapping

Cleanup partial state on failure.

**Full details**: @.claude/guides/worktree-setup-REFERENCE.md#error-trapping-cleans-up-partial-state-on-failure

---

## Workflow

### Create Worktree
```bash
git worktree add ../feature-branch feature-branch
cd ../feature-branch
```

### Initialize Plan
```bash
# /00_plan to create plan
# /02_execute --wt to initialize worktree mode
```

### Switch Worktrees
```bash
cd ../main-branch      # Switch to main worktree
cd ../feature-branch   # Switch to feature worktree
```

### Cleanup
```bash
git worktree remove ../feature-branch
```

---

## Best Practices

- **One Plan Per Worktree**: Each worktree tracks its own active plan
- **Lock Management**: Always acquire lock before plan operations
- **Error Handling**: Use traps to cleanup partial state
- **Pointer Validation**: Verify both pointers before accessing plan

---

## Troubleshooting

### Lock File Stuck
```bash
rm -f .claude-pilot/.pilot/plan/locks/worktree.lock
```

### Missing Active Pointer
```bash
PLAN_PATH="$(ls -1t .claude-pilot/.pilot/plan/in_progress/*.md | head -1)"
printf "%s" "$PLAN_PATH" > .claude-pilot/.pilot/plan/active/$(git rev-parse --abbrev-ref HEAD).txt
```

### State Conflicts
```bash
ls -la .claude-pilot/.pilot/plan/active/
cat .claude-pilot/.pilot/plan/active/*.txt
rm -rf .claude-pilot/.pilot/plan/active/
mkdir -p .claude-pilot/.pilot/plan/active/
```

---

## See Also

- **@.claude/commands/02_execute.md** - Execution Command
- **@.claude/guides/prp-framework.md** - Plan Management
- **@.claude/skills/git-master/SKILL.md** - Git Workflow

---

**Version**: claude-pilot 4.2.0 (Worktree Setup)
**Last Updated**: 2026-01-19
