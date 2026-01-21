#!/bin/bash
# worktree-lock.sh - Atomic lock management for parallel plan execution
#
# Lock files are manually recoverable: ls .pilot/plan/.locks/
# Full procedures documented in: @.claude/skills/using-git-worktrees/SKILL.md
#
# Usage:
#   source .claude/lib/worktree-lock.sh
#   locked_plan=$(acquire_lock)  # Returns path to locked plan, or empty
#   release_lock "$plan_file"     # Release lock

# Acquire atomic lock on oldest pending plan
# Usage: locked_plan=$(acquire_lock)
# Returns: Path to locked plan, or empty if none available
# Lock mechanism: Atomic mkdir (POSIX-compliant)
acquire_lock() {
  local lock_dir=".pilot/plan/.locks"
  mkdir -p "$lock_dir"

  # Find oldest pending plan
  for plan in $(find .pilot/plan/pending -maxdepth 1 -type f -name "*.md" 2>/dev/null | xargs ls -1tr 2>/dev/null); do
    local plan_name="$(basename "$plan")"
    local lock_file="${lock_dir}/${plan_name}.lock"

    # Atomic lock attempt using mkdir (atomic on POSIX)
    if mkdir "$lock_file" 2>/dev/null; then
      # Verify plan still exists AFTER lock acquired (race condition fix)
      if [ ! -f "$plan" ]; then
        rmdir "$lock_file"  # Release lock
        continue  # Try next plan
      fi
      # Lock acquired and plan verified
      echo "$plan"
      return 0
    fi
    # Lock failed - try next plan
  done

  # No available plans
  return 1
}

# Release lock for a plan file
# Usage: release_lock "$plan_file"
release_lock() {
  local plan_file="$1"
  local plan_name="$(basename "$plan_file")"
  local lock_file=".pilot/plan/.locks/${plan_name}.lock"

  if [ -d "$lock_file" ]; then
    rmdir "$lock_file" 2>/dev/null || true
  fi
}

# Check if plan is locked
# Usage: is_locked "$plan_file"
# Returns: 0 if locked, 1 if not locked
is_locked() {
  local plan_file="$1"
  local plan_name="$(basename "$plan_file")"
  local lock_file=".pilot/plan/.locks/${plan_name}.lock"

  [ -d "$lock_file" ]
}

# List all active locks
# Usage: list_locks
# Returns: List of locked plan names
list_locks() {
  local lock_dir=".pilot/plan/.locks"
  if [ -d "$lock_dir" ]; then
    find "$lock_dir" -type d -name "*.lock" 2>/dev/null | xargs -I {} basename {}
  fi
}
