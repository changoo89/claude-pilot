---
name: git-operations
description: Use when pushing, pulling, or merging changes. Handles retries, conflicts, and error recovery.
---

# SKILL: Git Operations

> **Purpose**: Safe push/pull/merge operations with retry logic and error handling
> **Target**: All git operations

---

## Quick Start

### When to Use This Skill
- Pushing changes to remote
- Pulling latest changes
- Merging branches
- Resolving merge conflicts

### Quick Reference
```bash
# Push with retry
git_push_with_retry() {
  local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
  local max_attempts=3
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if git push origin "$branch" 2>&1; then
      echo "✓ Push succeeded"
      return 0
    fi
    echo "Push attempt $attempt failed, retrying..."
    ((attempt++))
    sleep 2
  done
  echo "❌ Push failed after $max_attempts attempts" >&2
  return 1
}

# Pull with conflict detection
git_pull_safe() {
  if git pull --ff-only; then
    echo "✓ Fast-forward pull succeeded"
  else
    echo "⚠️  Diverged branches - manual merge required"
    return 1
  fi
}
```

---

## Core Operations

### Push with Retry

**Purpose**: Handle transient network failures

**Implementation**:
```bash
git_push_with_retry() {
  local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"
  local remote="${2:-origin}"
  local max_attempts=3
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if git push "$remote" "$branch" 2>&1; then
      echo "✓ Pushed to $remote/$branch"
      return 0
    fi

    # Check if error is transient
    if gitLastError | grep -qiE "network|connection|timeout"; then
      echo "Network error (attempt $attempt/$max_attempts), retrying..."
      ((attempt++))
      sleep 2
    else
      echo "Non-retryable error:" >&2
      gitLastError >&2
      return 1
    fi
  done

  echo "❌ Failed to push after $max_attempts attempts" >&2
  return 1
}
```

### Pull with Safety Checks

**Purpose**: Avoid destructive merges

**Implementation**:
```bash
git_pull_safe() {
  local remote="${1:-origin}"
  local branch="${1:-$(git rev-parse --abbrev-ref HEAD)}"

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "❌ Uncommitted changes detected. Commit or stash first." >&2
    return 1
  fi

  # Try fast-forward pull
  if git pull --ff-only "$remote" "$branch" 2>&1; then
    echo "✓ Pulled from $remote/$branch (fast-forward)"
    return 0
  fi

  # Check if diverged
  local local_commit=$(git rev-parse HEAD)
  local remote_commit=$(git rev-parse "$remote/$branch")

  if [ "$local_commit" != "$remote_commit" ]; then
    echo "⚠️  Branches have diverged - manual merge required"
    echo "  Local:  $local_commit"
    echo "  Remote: $remote_commit"
    return 1
  fi

  return 1
}
```

### Merge with Verification

**Purpose**: Safe branch merging with conflict resolution

**Implementation**:
```bash
git_merge_safe() {
  local source_branch="$1"
  local target_branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"

  echo "Merging $source_branch into $target_branch..."

  # Checkout target branch
  git checkout "$target_branch" || return 1

  # Attempt merge
  if git merge "$source_branch" --no-ff --no-edit; then
    echo "✓ Merged $source_branch into $target_branch"
    return 0
  fi

  # Conflict detected
  echo "⚠️  Merge conflicts detected"
  echo "Files with conflicts:"
  git diff --name-only --diff-filter=U

  echo ""
  echo "Resolve conflicts, then run:"
  echo "  git add <resolved-files>"
  echo "  git commit"

  return 1
}
```

---

## Conflict Resolution

### Resolve Conflicts

**Manual resolution workflow**:
```bash
# After merge conflict
git status  # List conflicted files

# Edit conflicted files, resolve markers
vim conflicted-file.ts

# Mark as resolved
git add conflicted-file.ts

# Complete merge
git commit
```

### Abort Failed Operations

```bash
# Abort merge
git merge --abort

# Abort rebase
git rebase --abort

# Reset to safe state
git reset --hard HEAD
```

---

## Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Failed to connect` | Network issue | Retry with `git_push_with_retry` |
| `rejected (non-fast-forward)` | Remote has new commits | Pull first, then push |
| `conflict` | Branches diverged | Manual merge required |
| `uncommitted changes` | Dirty working tree | Commit or stash first |

### Error Recovery

```bash
# Safe error recovery
git_operation_with_fallback() {
  local operation="$1"

  if ! eval "$operation"; then
    echo "⚠️  Operation failed: $operation"

    # Check for known errors
    if gitLastError | grep -qi "connection"; then
      echo "Network error - will retry"
      return 2  # Retryable
    elif gitLastError | grep -qi "conflict"; then
      echo "Merge conflict - manual resolution required"
      return 3  # Needs intervention
    else
      echo "Unknown error - aborting"
      return 1  # Fatal
    fi
  fi
}
```

---

## Verification

### Test Git Operations
```bash
# Test push with retry
git_push_with_retry test-branch

# Test pull safety
git_pull_safe

# Test merge safety
git_merge_safe feature-branch main
```

---

## Related Skills

- **using-git-worktrees**: Parallel development in isolated workspaces
- **git-master**: Comprehensive git workflow mastery

---

**Version**: claude-pilot 4.2.0
